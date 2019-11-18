//
//  AnalysysSDK.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "AnalysysSDK.h"

#import <UIKit/UIKit.h>

#import "AnalysysAgentConfig.h"
#import "ANSConsoleLog.h"
#import "ANSDatabase.h"
#import "ANSDeviceInfo.h"
#import "ANSTelephonyNetwork.h"
#import "ANSFileManager.h"
#import "ANSSession.h"
#import "ANSUploadManager.h"
#import "ANSHybrid.h"

#import "ANSUtil.h"
#import "ANSDateUtil.h"
#import "ANSEncryptUtis.h"
#import "ANSConst+private.h"
#import "ANSGzip.h"

#import "ANSDataProcessing.h"
#import "ANSModuleProcessing.h"
#import "ANSDataCheckRouter.h"

#import "ANSPageAutoTrack.h"
#import "ANSOpenURLAutoTrack.h"
#import "ANSHeatMapAutoTrack.h"

#import "ANSStrategyManager.h"

#import "ANSTimeCheckManager.h"

#define AgentLock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER);
#define AgentUnlock() dispatch_semaphore_signal(self->_lock);

static AnalysysSDK *sharedInstance = nil;

//  默认上传端口
static NSString *const ANSHttpsDefaultPort = @"4089";


/**
 reset类型
 - ANSStartReset: 启动重置(切换appkey、serverUrl、debug模式)
 - ANSProfileReset: profile接口调用重置
 */
typedef NS_ENUM(NSInteger, ANSResetType) {
    ANSStartReset,
    ANSProfileReset
};

void* AnalysysQueueTag = &AnalysysQueueTag;

@interface AnalysysSDK () {
    
}

@property (atomic, strong) NSDictionary *commonProperties;  // 自定义常用属性
@property (atomic, strong) NSDictionary *superProperties;   // 用户通用属性
@property (nonatomic, copy) NSString *userId;  //  当前用户

@end


@implementation AnalysysSDK {
    ANSUploadManager *_uploadManager;
    ANSDatabase *_dbHelper;
    dispatch_queue_t _serialQueue;  //  数据队列
    dispatch_queue_t _requestQueue; //  数据队列
    NSMutableArray *_ignoredViewControllers;    //  忽略自动采集的页面
    
    BOOL _isAppLaunched;    // 是否launch启动，防止pageview事件先于start事件
    BOOL _canSendProfileSetOnce;    // 是否可发送profileSetOnce
    BOOL _canSendAutoInstallation;  // 是否可发送渠道追踪
    BOOL _isAutoCollectionPage; // 页面自动采集
    dispatch_semaphore_t _lock;
    NSInteger _maxCacheSize;    // 本地允许最大缓存
    long long _appBecomeActiveTime; // App活跃点
    long long _appResignActiveTime; // App非活跃点
    
    NSLock *_propertiesLock;    // properties 专用锁 不要随便使用
    NSLock *_userDefaultsLock;  // userDefaults专用 对外暴露
    NSLock *_isSendingDataLock; // 数据发送锁
}

+ (instancetype)sharedManager {
    static id singleInstance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        singleInstance = [[self alloc] init] ;
    });
    return singleInstance;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _uploadManager = [[ANSUploadManager alloc] init];
        _isAppLaunched = YES;
        _lock = dispatch_semaphore_create(0);
        _isBackgroundActive = NO;
        _isAutoCollectionPage = YES;
        _maxCacheSize = 10000;
        _ignoredViewControllers = [NSMutableArray array];
        _appBecomeActiveTime = [ANSUtil nowTimeMilliseconds];
        _propertiesLock = [[NSLock alloc] init];
        _userDefaultsLock = [[NSLock alloc] init];
        _isSendingDataLock = [[NSLock alloc] init];
        
        NSString *serialLabel = [NSString stringWithFormat:@"com.analysys.serialQueue"];
        NSString *requestLabel = [NSString stringWithFormat:@"com.analysys.requestQueue"];
        _serialQueue = dispatch_queue_create([serialLabel UTF8String], DISPATCH_QUEUE_SERIAL);
        _requestQueue = dispatch_queue_create([requestLabel UTF8String], DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_serialQueue, AnalysysQueueTag, &AnalysysQueueTag, NULL);
        [_propertiesLock lock];
        _superProperties = [ANSFileManager unarchiveSuperProperties];
        _commonProperties = [ANSFileManager unarchiveCommonProperties];
        [_propertiesLock unlock];
        
        [self updateUserId];
        
        [[ANSTelephonyNetwork shareInstance] startReachability];
        [self registNotifications];
        self->_dbHelper = [[ANSDatabase alloc] initWithDatabaseName:@"ANALYSYS.db"];
        [self->_dbHelper resetLogStatus];
    }
    return self;
}

- (void)startWithConfig:(AnalysysAgentConfig *)config {
    @try {
        static dispatch_once_t autoTrackOnceToken ;
        dispatch_once(&autoTrackOnceToken, ^{
            [ANSOpenURLAutoTrack autoTrack];
            [ANSPageAutoTrack autoTrack];
        });
        
        dispatch_block_t block = ^(){
            NSString *upServerUrl;
            if (config.baseUrl.length > 0) {
                upServerUrl = [NSString stringWithFormat:@"https://%@:%@/up", config.baseUrl, ANSHttpsDefaultPort];
                
                //  可视化模块
                [ANSModuleProcessing setVisualBaseUrl:config.baseUrl];
            }
            
            [self checkAppFirstStart];
            
            if ([self isAppKeyChanged:config.appKey] ||
                [self isServerURLChanged:upServerUrl]) {
                [self profileResetWithType:ANSStartReset];
            }
            
            NSLog(@"\n\n----------------------- [Analysys] [Log] ----------------------- \
                  \n------ Init iOS Analysys OC SDK Success. Version: %@ ------ \
                  \n----------------------------------------------------------------",ANSSDKVersion);
            
            [self trackAppStartEvent];
        };
        [self dispatchOnSerialQueue:block];
    } @catch (NSException *exception) {
        AnsDebug(@"SDK init exception: %@", exception);
    }
}

/** 当前SDK版本 */
+ (NSString *)SDKVersion {
    return ANSSDKVersion;
}

#pragma mark - --------- public interface ---------

#pragma mark - 服务器地址设置

/** 设置上传数据地址 */
- (void)setUploadURL:(NSString *)uploadURL {
    dispatch_block_t block = ^(){
        ANSConsoleLog *checkResult = [[ANSConsoleLog alloc] init];
        checkResult.value = uploadURL;
        
        NSString *url = [ANSUtil getHttpUrlString:uploadURL];
        if (url.length == 0) {
            [[ANSStrategyManager sharedManager] setUserServerUrlValue:nil];
            
            checkResult.resultType = AnalysysResultSetFailed;
            checkResult.remarks = @"'uploadURL' must start with 'http://' or 'https://'";
            ANSWarning(@"%@",[checkResult messageDisplay]);
            return;
        }
        NSString *serverUrl = [NSString stringWithFormat:@"%@/up",url];
        
        [[ANSTimeCheckManager shared] requestWithServer:serverUrl block:^{
            [self flushDataNotification:nil];
        }];
        
        if ([self isServerURLChanged:serverUrl]) {
            [self profileResetWithType:ANSStartReset];
        }
        
        checkResult.resultType = AnalysysResultSetSuccess;
        ANSLog(@"%@",[checkResult messageDisplay]);
    };
    [self dispatchOnSerialQueue:block];
}

/** 设置可视化websocket服务器地址 */
- (void)setVisitorDebugURL:(NSString *)visitorDebugURL {
    dispatch_block_t block = ^(){
        [ANSModuleProcessing setVisitorDebugURL:visitorDebugURL];
    };
    [self dispatchOnSerialQueue:block];
}

/** 设置线上请求埋点配置的服务器地址 */
- (void)setVisitorConfigURL:(NSString *)configURL {
    dispatch_block_t block = ^(){
        [ANSModuleProcessing setVisualConfigUrl:configURL];
    };
    [self dispatchOnSerialQueue:block];
}

/** 是否采集热图坐标 */
- (void)setAutomaticHeatmap:(BOOL)autoTrack {
    dispatch_block_t block = ^(){
        [ANSHeatMapAutoTrack heatMapAutoTrack:autoTrack];
    };
    [self dispatchOnSerialQueue:block];
}

#pragma mark - SDK发送策略

/** debug模式 */
- (void)setDebugMode:(AnalysysDebugMode)debugMode {
    dispatch_block_t block = ^(){
        switch (debugMode) {
            case AnalysysDebugOff:
            case AnalysysDebugOnly:
            case AnalysysDebugButTrack: {
                if ([self isDebugModeChanged:debugMode]) {
                    [self profileResetWithType:ANSStartReset];
                }
                ANSConsoleLog *checkResult = [[ANSConsoleLog alloc] init];
                checkResult.resultType = AnalysysResultSetSuccess;
                checkResult.value = [NSNumber numberWithInteger:debugMode];
                ANSLog(@"%@",[checkResult messageDisplay]);
            }
                break;
            default:
                break;
        }
    };
    [self dispatchOnSerialQueue:block];
}

/** 当前调试模式 */
- (AnalysysDebugMode)debugMode {
    AnalysysDebugMode debugMode = [ANSStrategyManager sharedManager].currentUseDebugMode;
    return debugMode;
}

/** 设置上传间隔时间 */
- (void)setIntervalTime:(NSInteger)flushInterval {
    dispatch_block_t block = ^(){
        NSInteger _flushInterval = MAX(1, flushInterval);
        [[ANSStrategyManager sharedManager] setUserIntervalTimeValue:_flushInterval];
        
        ANSConsoleLog *checkResult = [[ANSConsoleLog alloc] init];
        checkResult.resultType = AnalysysResultSetSuccess;
        checkResult.value = [NSNumber numberWithInteger:_flushInterval];
        ANSLog(@"%@",[checkResult messageDisplay]);
    };
    [self dispatchOnSerialQueue:block];
}

/** 数据累积"size"条数后触发上传 */
- (void)setMaxEventSize:(NSInteger)flushSize {
    dispatch_block_t block = ^(){
        NSInteger _flushSize = MAX(1, flushSize);
        [[ANSStrategyManager sharedManager] setUserMaxEventSizeValue:_flushSize];
        
        ANSConsoleLog *checkResult = [[ANSConsoleLog alloc] init];
        checkResult.resultType = AnalysysResultSetSuccess;
        checkResult.value = [NSNumber numberWithInteger:_flushSize];
        ANSLog(@"%@",[checkResult messageDisplay]);
    };
    [self dispatchOnSerialQueue:block];
}

/** 本地缓存上限值 */
- (void)setMaxCacheSize:(NSInteger)cacheSize {
    _maxCacheSize = MAX(100, cacheSize);
    
    ANSConsoleLog *checkResult = [[ANSConsoleLog alloc] init];
    checkResult.resultType = AnalysysResultSetSuccess;
    checkResult.value = [NSNumber numberWithInteger:_maxCacheSize];
    ANSLog(@"%@",[checkResult messageDisplay]);
}

/** 获取当前设置的本地最大存储 */
- (NSInteger)maxCacheSize {
    return _maxCacheSize;
}

/** 主动向服务器上传数据 */
- (void)flush {
    dispatch_block_t block = ^(){
        [self flushDataIfIgnorePolicy:YES];
    };
    [self dispatchOnSerialQueue:block];
}

#pragma mark - 热图

- (void)trackHeatMapWithSDKProperties:(NSDictionary *)sdkProperties  {
    dispatch_block_t block = ^(){
        NSDictionary *heatMap = [ANSDataProcessing processHeatMapWithSDKProperties:sdkProperties];
        [self saveUploadInfo:heatMap event:ANSEventHeatMap handler:^{}];
    };
    [self dispatchOnSerialQueue:block];
}

#pragma mark - 事件

/** 添加事件及附加属性 */
- (void)track:(NSString *)event properties:(NSDictionary *)properties {
    NSDictionary *tProperties = [properties mutableCopy];
    dispatch_block_t block = ^(){
        ANSConsoleLog *checkResult = [ANSDataCheckRouter checkEvent:event];
        if (checkResult) {
            ANSWarning(@"%@",[checkResult messageDisplay]);
            return ;
        }
        
        NSDictionary *trackInfo = [ANSDataProcessing processTrack:event properties:tProperties];
        [self saveUploadInfo:trackInfo event:ANSEventTrack handler:^{}];
    };
    [self dispatchOnSerialQueue:block];
}

#pragma mark - 页面事件

/** 页面跟踪及附加属性 */
- (void)pageView:(NSString *)pageName properties:(NSDictionary *)properties {
    if (![pageName isKindOfClass:NSString.class]) {
        pageName = nil;
        ANSWarning(@"pagename is not <NSString>.");
    } else if ([pageName isKindOfClass:NSString.class] && pageName.length == 0) {
        pageName = nil;
        ANSWarning(@"pagename is empty.");
    }
    [self trackPageView:pageName properties:properties];
}

/** SDK页面自动采集 */
- (void)autoPageView:(NSString *)pageName properties:(NSDictionary *)properties {
    [self trackPageView:pageName properties:properties];
}

/** 设置是否允许页面自动采集 */
- (void)setAutomaticCollection:(BOOL)isAuto {
    [_propertiesLock lock];
    _isAutoCollectionPage = isAuto;
    [_propertiesLock unlock];
}

/** 当前SDK是否允许页面自动跟踪 */
- (BOOL)isViewAutoTrack {
    [_propertiesLock lock];
    BOOL retValue = _isAutoCollectionPage;
    [_propertiesLock unlock];
    return retValue;
}

/** 忽略部分页面自动采集 */
- (void)setIgnoredAutomaticCollectionControllers:(NSArray<NSString *> *)controllers {
    NSArray *sControllers = [controllers mutableCopy];
    if (sControllers.count == 0 || ![sControllers isKindOfClass:NSArray.class]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_propertiesLock lock];
        [self->_ignoredViewControllers addObjectsFromArray:sControllers];
        [self->_propertiesLock unlock];
    });
}

#pragma mark - 通用属性

/** 注册通用属性 */
- (void)registerSuperProperties:(NSDictionary *)superProperties {
    __block NSDictionary *blockSuperProperties = [superProperties mutableCopy];
    dispatch_block_t block = ^(){
        ANSConsoleLog *checkResult = [ANSDataCheckRouter checkSuperProperties:&blockSuperProperties];
        if (checkResult && checkResult.resultType <= AnalysysResultSuccess) {
            ANSWarning(@"%@",[checkResult messageDisplay]);
            if (blockSuperProperties == nil) {
                return;
            }
        }
        [self->_propertiesLock lock];
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self->_superProperties];
        [tmp addEntriesFromDictionary:blockSuperProperties];
        self->_superProperties = [NSDictionary dictionaryWithDictionary:tmp];
        BOOL result = [ANSFileManager archiveSuperProperties:self->_superProperties];
        [self->_propertiesLock unlock];
        if (result) {
            ANSConsoleLog *checkResult = [[ANSConsoleLog alloc] init];
            checkResult.resultType = AnalysysResultSetSuccess;
            ANSLog(@"%@",[checkResult messageDisplay]);
        } else {
            ANSConsoleLog *checkResult = [[ANSConsoleLog alloc] init];
            checkResult.resultType = AnalysysResultSetFailed;
            ANSWarning(@"%@",[checkResult messageDisplay]);
        }
    };
    [self dispatchOnSerialQueue:block];
}

/** 添加单个通用属性 */
- (void)registerSuperProperty:(NSString *)superPropertyName value:(id)superPropertyValue {
    if (superPropertyName && superPropertyValue) {
        [self registerSuperProperties:@{superPropertyName: superPropertyValue}];
    }
}

/** 删除单个通用属性 */
- (void)unRegisterSuperProperty:(NSString *)superPropertyName {
    if (superPropertyName.length == 0) {
        return;
    }
    dispatch_block_t block = ^(){
        [self->_propertiesLock lock];
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
        [tmp removeObjectForKey:superPropertyName];
        self.superProperties = [NSDictionary dictionaryWithDictionary:tmp];
        BOOL result = [ANSFileManager archiveSuperProperties:self.superProperties];
        [self->_propertiesLock unlock];
        if (result) {
            ANSConsoleLog *checkResult = [[ANSConsoleLog alloc] init];
            checkResult.value = superPropertyName;
            checkResult.resultType = AnalysysResultSetSuccess;
            ANSLog(@"%@",[checkResult messageDisplay]);
        }
    };
    [self dispatchOnSerialQueue:block];
}

/** 清除所有通用属性 */
- (void)clearSuperProperties {
    dispatch_block_t block = ^{
        [self->_propertiesLock lock];
        self.superProperties = [NSDictionary dictionary];
        BOOL result = [ANSFileManager archiveSuperProperties:self.superProperties];
        [self->_propertiesLock unlock];
        if (result) {
            ANSConsoleLog *checkResult = [[ANSConsoleLog alloc] init];
            checkResult.resultType = AnalysysResultSetSuccess;
            ANSLog(@"%@",[checkResult messageDisplay]);
        }
    };
    [self dispatchOnSerialQueue:block];
}

/** 获取通用属性 */
- (NSDictionary *)getSuperPropertiesValue {
    [_propertiesLock lock];
    NSDictionary *retValue = [_superProperties copy];
    [_propertiesLock unlock];
    return retValue;
}

/** 获取某个通用属性 */
- (id)getSuperProperty:(NSString *)superPropertyName {
    [_propertiesLock lock];
    id retValue = _superProperties[superPropertyName];
    [_propertiesLock unlock];
    return retValue;
}

/** 普通属性 */
- (NSDictionary *)getCommonProperties {
    [_propertiesLock lock];
    NSDictionary *retValue = [_commonProperties copy];
    [_propertiesLock unlock];
    return retValue;
}

- (NSDictionary *)getPresetProperties {
    NSMutableDictionary *presetProperties = [NSMutableDictionary dictionary];
    
    [presetProperties setValue:[ANSDeviceInfo getTimeZone] forKey:ANSPresetTimeZone];
    [presetProperties setValue:[ANSDeviceInfo getAppVersion] forKey:ANSPresetAppVersion];
    [presetProperties setValue:[ANSDeviceInfo getDeviceLanguage] forKey:ANSPresetLanguage];
    [presetProperties setValue:[NSNumber numberWithFloat:[ANSDeviceInfo getScreenWidth]] forKey:ANSPresetScreenWidth];
    [presetProperties setValue:[NSNumber numberWithFloat:[ANSDeviceInfo getScreenHeight]] forKey:ANSPresetScreenHeight];
    [presetProperties setValue:[ANSDeviceInfo getIdfv] forKey:ANSPresetIDFV];
    [presetProperties setValue:[ANSDeviceInfo getIDFA] forKey:ANSPresetIDFA];
    [presetProperties setValue:[ANSDeviceInfo getDeviceModel] forKey:ANSPresetModel];
    
    NSString *netWork = [[ANSTelephonyNetwork shareInstance] telephonyNetworkDescrition];
    [presetProperties setValue:netWork forKey:ANSPresetNetwork];
    
    [presetProperties setValue:[self appFirstStartTime] forKey:ANSPresetFirstVisitTime];
    
    NSString *session = [[ANSSession shareInstance] localSession];
    [presetProperties setValue:session forKey:ANSSessionId];
    
    [presetProperties setValue:ANSSDKVersion forKey:ANSPresetLibVersion];
    [presetProperties setValue:@"iOS" forKey:ANSPresetPlatform];
    [presetProperties setValue:@"iOS" forKey:ANSPresetLib];
    [presetProperties setValue:@"iOS" forKey:ANSPresetOS];
    [presetProperties setValue:@"Apple" forKey:ANSPresetManufacturer];
    [presetProperties setValue:@"Apple" forKey:ANSPresetBrand];
    
    return [presetProperties copy];
}

#pragma mark - 用户信息相关

/** 匿名用户ID设置 */
- (void)identify:(NSString *)anonymousId {
    
    dispatch_block_t block = ^(){
        ANSConsoleLog *checkResult = [ANSDataCheckRouter checkLengthOfIdentify:anonymousId];
        if (checkResult && checkResult.resultType < AnalysysResultSuccess) {
            ANSWarning(@"%@",[checkResult messageDisplay]);
            return;
        }
        [self->_propertiesLock lock];
        NSMutableDictionary *tmpCommonProperties = [NSMutableDictionary dictionaryWithDictionary:self->_commonProperties];
        [tmpCommonProperties setValue:anonymousId forKey:ANSAnonymousId];
        self->_commonProperties = [NSDictionary dictionaryWithDictionary:tmpCommonProperties];
        BOOL result = [ANSFileManager archiveCommonProperties:self->_commonProperties];
        [self->_propertiesLock unlock];
        
        [self updateUserId];
        
        if (result) {
            ANSConsoleLog *checkResult = [[ANSConsoleLog alloc] init];
            checkResult.value = anonymousId;
            checkResult.resultType = AnalysysResultSetSuccess;
            ANSLog(@"%@",[checkResult messageDisplay]);
        }
    };
    [self dispatchOnSerialQueue:block];
}

/** 用户关联 */
- (void)alias:(NSString *)aliasId originalId:(NSString *)originalId {
    dispatch_block_t block = ^(){
        ANSConsoleLog *checkResult = [ANSDataCheckRouter checkLengthOfAliasId:aliasId];
        if (checkResult) {
            ANSWarning(@"%@",[checkResult messageDisplay]);
            return ;
        }
        checkResult = [ANSDataCheckRouter checkAliasOriginalId:originalId];
        if (checkResult) {
            ANSWarning(@"%@",[checkResult messageDisplay]);
            return ;
        }
        [self->_propertiesLock lock];
        NSMutableDictionary *tmpCommonProperties = [NSMutableDictionary dictionaryWithDictionary:self->_commonProperties];
        [tmpCommonProperties setValue:aliasId forKey:ANSEventAlias];
        [tmpCommonProperties setValue:originalId forKey:ANSOriginalId];
        self->_commonProperties = [NSDictionary dictionaryWithDictionary:tmpCommonProperties];
        [ANSFileManager archiveCommonProperties:self->_commonProperties];
        
        [self updateUserId];
        
        // original_id
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        NSString *anonymousId = self.commonProperties[ANSAnonymousId];
        if (originalId.length > 0) {
            [properties setValue:originalId forKey:ANSOriginalId];
        } else if (anonymousId.length > 0) {
            [properties setValue:anonymousId forKey:ANSOriginalId];
        } else {
            [properties setValue:self.commonProperties[ANSUUID] forKey:ANSOriginalId];
        }
        [self->_propertiesLock unlock];
        NSDictionary *aliasInfo = [ANSDataProcessing processAliasSDKProperties:properties];
        [self saveUploadInfo:aliasInfo event:ANSEventAlias handler:^{}];
        [self upProfileSetOnce];
    };
    [self dispatchOnSerialQueue:block];
}

- (NSString *)getDistinctIdInternal {
    [_propertiesLock lock];
    NSString *anonymousId = self.commonProperties[ANSAnonymousId];
    NSString *distictId;
    if (anonymousId.length > 0) {
        distictId = anonymousId;
    } else {
        distictId = self.commonProperties[ANSUUID];
    }
    [_propertiesLock unlock];
    return distictId;
}
/** 获取用户的匿名ID*/
- (NSString *)getDistinctId {
    NSString * returnedDistinctId = [self getDistinctIdInternal];
    return returnedDistinctId;
}

/** 设置用户属性 */
- (void)profileSet:(NSDictionary *)property {
    NSDictionary *sProperties = [property mutableCopy];
    dispatch_block_t block = ^(){
        NSDictionary *upInfo = [ANSDataProcessing processProfileSetProperties:sProperties];
        [self saveUploadInfo:upInfo event:ANSEventProfileSet handler:^{}];
    };
    [self dispatchOnSerialQueue:block];
}

- (void)profileSet:(NSString *)propertyName propertyValue:(id)propertyValue {
    if (propertyName && propertyValue) {
        [self profileSet:@{propertyName: propertyValue}];
    } else {
        [self profileSet:nil];
    }
}

/** 设置用户固有属性 */
- (void)profileSetOnce:(NSDictionary *)property {
    NSDictionary *sProperties = [property mutableCopy];
    dispatch_block_t block = ^(){
        NSDictionary *upInfo = [ANSDataProcessing processProfileSetOnceProperties:sProperties SDKProperties:nil];
        [self saveUploadInfo:upInfo event:ANSEventProfileSetOnce handler:^{}];
    };
    [self dispatchOnSerialQueue:block];
}

- (void)profileSetOnce:(NSString *)propertyName propertyValue:(id)propertyValue {
    if (propertyName && propertyValue) {
        [self profileSetOnce:@{propertyName: propertyValue}];
    } else {
        [self profileSetOnce:nil];
    }
}

/** 设置用户属性相对变化值 */
- (void)profileIncrement:(NSDictionary<NSString*, NSNumber*> *)property {
    NSDictionary *sProperties = [property mutableCopy];
    __block NSDictionary *blockProperty = sProperties;
    dispatch_block_t block = ^(){
        ANSConsoleLog *checkResult = [ANSDataCheckRouter checkIncrementProperties:&blockProperty];
        if (checkResult && checkResult.resultType < AnalysysResultSuccess) {
            ANSWarning(@"%@",[checkResult messageDisplay]);
        }
        
        NSDictionary *upInfo = [ANSDataProcessing processProfileIncrementProperties:blockProperty];
        [self saveUploadInfo:upInfo event:ANSEventProfileIncrement handler:^{}];
    };
    [self dispatchOnSerialQueue:block];
}

/** profileIncrement */
- (void)profileIncrement:(NSString *)propertyName propertyValue:(NSNumber *)propertyValue {
    if (propertyName && propertyValue) {
        [self profileIncrement:@{propertyName: propertyValue}];
    } else {
        [self profileIncrement:nil];
    }
}

/** 增加列表类型的属性 */
- (void)profileAppend:(NSDictionary *)property {
    NSDictionary *sProperties = [property mutableCopy];
    __block NSDictionary *blockProperty = sProperties;
    dispatch_block_t block = ^(){
        ANSConsoleLog *checkResult = nil;
        checkResult = [ANSDataCheckRouter checkAppendProperties:&blockProperty];
        if (checkResult && checkResult.resultType < AnalysysResultSuccess) {
            ANSWarning(@"%@",[checkResult messageDisplay]);
        }
        
        NSDictionary *upInfo = [ANSDataProcessing processProfileAppendProperties:blockProperty];
        [self saveUploadInfo:upInfo event:ANSEventProfileAppend handler:^{}];
    };
    [self dispatchOnSerialQueue:block];
}

/** 增加key-value用户属性 */
- (void)profileAppend:(NSString *)propertyName value:(id)propertyValue {
    if (propertyName && propertyValue) {
        [self profileAppend:@{propertyName: propertyValue}];
    } else {
        [self profileAppend:nil];
    }
}

/** 增加key-value set集合用户属性 */
- (void)profileAppend:(NSString *)propertyName propertyValue:(NSSet<NSString *> *)propertyValue {
    if (propertyName && propertyValue) {
        [self profileAppend:@{propertyName: propertyValue}];
    } else {
        [self profileAppend:nil];
    }
}

/** 删除某个用户属性 */
- (void)profileUnset:(NSString *)propertyName {
    if (propertyName.length == 0) {
        return;
    }
    dispatch_block_t block = ^(){
        NSDictionary *upInfo = [ANSDataProcessing processProfileUnsetWithSDKProperties:@{propertyName: @""}];
        [self saveUploadInfo:upInfo event:ANSEventProfileUnset handler:^{}];
    };
    [self dispatchOnSerialQueue:block];
}

/** 删除当前用户的所有属性 */
- (void)profileDelete {
    dispatch_block_t block = ^(){
        NSDictionary *upInfo = [ANSDataProcessing processProfileDelete];
        [self saveUploadInfo:upInfo event:ANSEventProfileDelete handler:^{}];
    };
    [self dispatchOnSerialQueue:block];
}

#pragma mark - 清除本地设置

/** 清除本地设置 */
- (void)reset {
    [self profileResetWithType:ANSProfileReset];
    [self sendResetInfo];
}

#pragma mark - Hybrid 页面

/** UIWebView和WKWebView统计 */
- (BOOL)setHybridModel:(id)webView request:(NSURLRequest *)request {
    if (webView == nil) {
        return NO;
    }
    @try {
        return [ANSHybrid excuteRequest:request webView:webView];
    } @catch (NSException *exception) {
        ANSError(@"Hyrbrid error:%@!", exception.description);
    }
}

/** 结束 Hybrid 模式 */
- (void)resetHybridModel {
    [ANSHybrid resetHybridModel];
}

#pragma mark - 活动推送效果

/** 设置推送平台及第三方推送标识 */
- (void)setPushProvider:(AnalysysPushProvider)provider pushID:(NSString *)pushID {
    if (![ANSModuleProcessing existsPushModule]) {
        return;
    }
    dispatch_block_t block = ^(){
        NSMutableDictionary *pushDic = [NSMutableDictionary dictionary];
        switch (provider) {
            case AnalysysPushJiGuang:
                [pushDic setValue:pushID forKey:@"$JPUSH"];
                break;
            case AnalysysPushGeTui:
                [pushDic setValue:pushID forKey:@"$GETUI"];
                break;
            case AnalysysPushBaiDu:
                [pushDic setValue:pushID forKey:@"$BAIDU"];
                break;
            case AnalysysPushXiaoMi:
                [pushDic setValue:pushID forKey:@"$XIAOMI"];
                break;
            case AnalysysPushXinGe:
                [pushDic setValue:pushID forKey:@"$XINGE"];
                break;
            case AnalysysPushAPNS:
                [pushDic setValue:pushID forKey:@"$APNS"];
                break;
            default:
                break;
        }
        NSDictionary *upInfo = [ANSDataProcessing processProfileSetProperties:pushDic];
        [self saveUploadInfo:upInfo event:ANSEventPush handler:^{}];
    };
    [self dispatchOnSerialQueue:block];
}

/** 追踪活动推广，可回调用户自定义信息 */
- (void)trackCampaign:(id)userInfo isClick:(BOOL)isClick userCallback:(void(^ _Nullable )(id campaignInfo))userCallback {
    dispatch_block_t block = ^(){
        NSDictionary *analysysPushInfo = [ANSModuleProcessing parsePushInfo:userInfo];
        if (analysysPushInfo) {
            if (userCallback) {
                userCallback(analysysPushInfo);
            }
            //  防止App活着时，收到推送消息处理早于start事件，造成session不一致
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), self->_serialQueue, ^{
                [self handlePushInfo:analysysPushInfo isClick:isClick];
            });
        }
    };
    [self dispatchOnSerialQueue:block];
}

/** 处理推送通知 */
- (void)handlePushInfo:(NSDictionary *)analysysPushInfo isClick:(BOOL)isClick {
    NSDictionary *contextProperty = [ANSModuleProcessing parsePushContext:analysysPushInfo];
    if (!contextProperty) {
        return;
    }
    
    NSDictionary *pushReceiverInfo = [ANSDataProcessing processSDKEvent:@"$push_receiver_success" properties:contextProperty];
    
    [self saveUploadInfo:pushReceiverInfo event:ANSEventPush handler:^{}];
    
    if (isClick) {
        NSDictionary *pushClickInfo = [ANSDataProcessing processSDKEvent:@"$push_click" properties:contextProperty];
        [self saveUploadInfo:pushClickInfo event:ANSEventPush handler:^{}];
        
        [ANSModuleProcessing pushClickParameter:analysysPushInfo];
        
        NSDictionary *pushProcessInfo = [ANSDataProcessing processSDKEvent:@"$push_process_success" properties:contextProperty];
        [self saveUploadInfo:pushProcessInfo event:ANSEventPush handler:^{}];
    }
}

#pragma mark - --------- private method ---------

#pragma mark - 队列

/** 串行队列 */
- (void)dispatchOnSerialQueue:(void(^)(void))dispatchBlock {
    if (dispatch_get_specific(AnalysysQueueTag)) {
        dispatchBlock();
    } else {
        dispatch_async(_serialQueue, dispatchBlock);
    }
}

#pragma mark - 重要信息改变

/** appKey是否更改 */
- (BOOL)isAppKeyChanged:(NSString *)appKey {
    NSString *lastAppKey = [ANSFileManager usedAppKey];
    [ANSFileManager saveAppKey:appKey];
    
    if (lastAppKey.length > 0 && ![lastAppKey isEqualToString:appKey]) {
        return YES;
    }
    return NO;
}

/** 上传地址是否更改 */
- (BOOL)isServerURLChanged:(NSString *)serverUrl {
    if (serverUrl.length > 0) {
        NSString *lastServer = [[ANSStrategyManager sharedManager] currentUrl];
        [[ANSStrategyManager sharedManager] setUserServerUrlValue:serverUrl];
        
        if (lastServer.length > 0 && serverUrl.length > 0 && ![lastServer isEqualToString:serverUrl]) {
            return YES;
        }
    }
    return NO;
}

/** debug模式是否更改 */
- (BOOL)isDebugModeChanged:(AnalysysDebugMode)debugMode {
    AnalysysDebugMode lastDebug = [ANSStrategyManager sharedManager].currentUseDebugMode;
    [[ANSStrategyManager sharedManager] setUserDebugModeValue:debugMode];
    
    if ((lastDebug == AnalysysDebugOnly && debugMode == AnalysysDebugButTrack) ||
        (lastDebug == AnalysysDebugOnly && debugMode == AnalysysDebugOff)) {
        return YES;
    }
    return NO;
}

#pragma mark - 通知及处理

/** 通知 */
- (void)registNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidBecomeActiveNotification:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillResignActiveNotification:)
                               name:UIApplicationWillResignActiveNotification
                             object:nil];
    //  策略相关通知
    [notificationCenter addObserver:self selector:@selector(flushDataNotification:) name:ANSFlushDataNotification object:nil];
}

/** App 变为活跃状态 */
- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification {
    _appBecomeActiveTime = [ANSUtil nowTimeMilliseconds];
    
    if (!_isAppLaunched) {
        dispatch_block_t block = ^(){
            [self trackAppStartEvent];
            [ANSPageAutoTrack autoTrackLastVisitPage];
        };
        [self dispatchOnSerialQueue:block];
    }
    _isAppLaunched = NO;
}

/** app变为非活跃状态 */
- (void)applicationWillResignActiveNotification:(NSNotification *)notification {
    _isAppLaunched = NO;
    _isBackgroundActive = YES;
    _appResignActiveTime = [ANSUtil nowTimeMilliseconds];
    dispatch_block_t block = ^(){
        [[ANSSession shareInstance] updatePageDisappearDate];
        
        NSDictionary *endEvent = [ANSDataProcessing processAppEnd];
        [self saveUploadInfo:endEvent event:ANSEventAppEnd handler:^{}];
    };
    [self dispatchOnSerialQueue:block];
}

/** 数据上传 */
- (void)flushDataNotification:(NSNotification *)notification {
    dispatch_async(self->_serialQueue, ^{
        [self flushDataIfIgnorePolicy:NO];
    });
}

#pragma mark - 事件处理

/** App启动事件 */
- (void)trackAppStartEvent {
    dispatch_block_t block = ^(){
        //  先生成session 后记录时间
        [[ANSSession shareInstance] generateSessionId];
        
        NSDictionary *utm = [ANSOpenURLAutoTrack utmParameters];
        [ANSOpenURLAutoTrack saveUtmParameters:nil];
        NSDictionary *startEvent = [ANSDataProcessing processAppStartProperties:utm];
        if (!startEvent) {
            ANSConsoleLog *checkResult = [[ANSConsoleLog alloc] init];
            checkResult.remarks = @"trackAppStartEvent failed!";
            ANSBriefWarning(@"%@",[checkResult messageDisplay]);
            return;
        }
        
        [self saveUploadInfo:startEvent event:ANSEventAppStart handler:^{}];
        
        if (self->_canSendProfileSetOnce) {
            [self upProfileSetOnce];
            self->_canSendProfileSetOnce = NO;
        }
        
        //  渠道追踪
        [self upFirstInstallation];
    };
    [self dispatchOnSerialQueue:block];
}

/** 页面数据 */
- (void)trackPageView:(NSString *)pageName properties:(NSDictionary *)properties {
    dispatch_block_t block = ^(){
        NSMutableDictionary *pageProperties = [NSMutableDictionary dictionary];
        [pageProperties setValue:pageName forKey:ANSPageName];
        if ([properties isKindOfClass:[NSDictionary class]]) {
            [pageProperties addEntriesFromDictionary:properties];
         } else if (properties) {
            pageProperties = properties;
        }
        NSDictionary *pageInfo = [ANSDataProcessing processPageProperties:pageProperties SDKProperties:nil];
        
        [self saveUploadInfo:pageInfo event:ANSEventPageView handler:^{}];
    };
    [self dispatchOnSerialQueue:block];
}

/** 上传一次 set_once 数据 */
- (void)upProfileSetOnce {
    dispatch_block_t block = ^(){
        if (AnalysysConfig.autoProfile) {
            NSDictionary *properties = @{ANSPresetFirstVisitTime: [self appFirstStartTime],
                                         ANSPresetFirstVisitLanguage: [ANSDeviceInfo getDeviceLanguage]};
            NSDictionary *setOnce = [ANSDataProcessing processProfileSetOnceProperties:nil SDKProperties:properties];
            [self saveUploadInfo:setOnce event:ANSEventProfileSetOnce handler:^{}];
        }
    };
    [self dispatchOnSerialQueue:block];
}

/** 渠道追踪 */
- (void)upFirstInstallation {
    dispatch_block_t block = ^(){
        if (self->_canSendAutoInstallation && AnalysysConfig.autoInstallation) {
            self->_canSendAutoInstallation = NO;
            NSDictionary *utm = [ANSOpenURLAutoTrack utmParameters];
            NSDictionary *attribute = [ANSDataProcessing processInstallationSDKProperties:utm];
            [self saveUploadInfo:attribute event:ANSEventInstallation handler:^{}];
        }
    };
    [self dispatchOnSerialQueue:block];
}

/** 重置本地缓存 */
- (void)profileResetWithType:(ANSResetType)resetType {
    dispatch_block_t block = ^(){
        
        [self->_propertiesLock lock];
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self->_commonProperties];
        if (resetType == ANSProfileReset) {
            [tmp setValue:[[NSUUID UUID] UUIDString] forKey:ANSUUID];
        }
        self->_canSendProfileSetOnce = YES;
        [tmp removeObjectForKey:ANSAnonymousId];
        [tmp removeObjectForKey:ANSEventAlias];
        [tmp removeObjectForKey:ANSOriginalId];
        self->_superProperties = [NSDictionary dictionary];
        [ANSFileManager archiveSuperProperties:self->_superProperties];
        self->_commonProperties = tmp;
        [ANSFileManager archiveCommonProperties:self->_commonProperties];
        [self->_propertiesLock unlock];
        
        [self updateUserId];
        
        [[ANSSession shareInstance] resetSession];
        
        [[ANSStrategyManager sharedManager] resetStrategy];

        [ANSFileManager saveUserDefaultWithKey:ANSAppLaunchDate value:nil];
        
        [self->_dbHelper clearDB];
    };
    [self dispatchOnSerialQueue:block];
}

/** 发送reset事件 */
- (void)sendResetInfo {
    dispatch_block_t block = ^(){
        if (AnalysysConfig.autoProfile) {
            ANSConsoleLog *checkResult = [[ANSConsoleLog alloc] init];
            checkResult.remarks = @"send reset info.";
            ANSBriefLog(@"%@",[checkResult messageDisplay]);
            
            NSString *dateStr = [[ANSDateUtil dateFormat] stringFromDate:[NSDate date]];
            NSDictionary *upInfo = [ANSDataProcessing processProfileSetOnceProperties:nil SDKProperties:@{ANSPresetResetTime: dateStr}];
            [self saveUploadInfo:upInfo event:ANSEventProfileSetOnce handler:^{}];
        }
    };
    [self dispatchOnSerialQueue:block];
}

#pragma mark - 数据存储及上传

/** 首次启动 */
- (void)checkAppFirstStart {
    NSString *launchDate = [ANSFileManager userDefaultValueWithKey:ANSAppLaunchDate];
    if (!launchDate) {
        _canSendProfileSetOnce = YES;
        _canSendAutoInstallation = YES;
        [_propertiesLock lock];
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:_commonProperties];
        [tmp setValue:[[NSUUID UUID] UUIDString] forKey:ANSUUID];
        self.commonProperties = tmp;
        [ANSFileManager archiveCommonProperties:self.commonProperties];
        [_propertiesLock unlock];
        
        [self updateUserId];
    }
}

/** 数据存储 */
- (void)saveUploadInfo:(NSDictionary *)dataInfo event:(NSString *)event handler:(void(^)(void))handler {
    if (!dataInfo) {
        return;
    }
    BOOL success = [_dbHelper insertRecordObject:dataInfo event:event];
    if (success) {
        if (handler) {
            handler();
        }
        //ANSLog(@"event:%@",dataInfo);
        [self uploadDataType:event];
    }
}

/** 根据条件上传数据 */
- (void)uploadDataType:(NSString *)eventType {
    if ([eventType isEqualToString:ANSEventAlias]) {
        //  alias不受策略控制
        [self flushDataIfIgnorePolicy:YES];
    } else {
        if ([[ANSStrategyManager sharedManager] canUploadWithDataCount:_dbHelper.recordRows] ) {
            [self flushDataIfIgnorePolicy:NO];
        }
    }
}

static BOOL isSendingData = NO;
/** 数据上传 */
- (void)flushDataIfIgnorePolicy:(BOOL)ignoreDelay {
    
    if (![[ANSTelephonyNetwork shareInstance] hasNetwork]) {
        ANSConsoleLog *checkResult = [[ANSConsoleLog alloc] init];
        checkResult.remarks = @"Please check the network status";
        ANSBriefWarning(@"%@",[checkResult messageDisplay]);
        return;
    }
    
    if (![[ANSTimeCheckManager shared] timeCheckRequestIsFinished]) {
        return;
    }
    
    [_isSendingDataLock lock];
    if (isSendingData) {
        [_isSendingDataLock unlock];
        return;
    }
    isSendingData = YES;
    [_isSendingDataLock unlock];
    BOOL (^uploadBlock)(NSString*, NSDictionary*, NSString*) = ^(NSString *serverUrl, NSDictionary *httpHeader, NSString *uploadInfo) {
        @try {
            __block BOOL uploadStatus = NO;
            [self->_uploadManager postRequestWithServerURLStr:serverUrl
                                                       header:httpHeader
                                                         body:uploadInfo
                                                      success:^(NSURLResponse *response, NSData *responseData) {
                  @try {
                      NSData *decodBase64Data = [[NSData alloc] initWithBase64EncodedData:responseData options:0];
                      NSError *error = nil;
                      NSDictionary *responseDict;
                      if (decodBase64Data == nil && responseData) {
                          responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
                      } else {
                          NSData *unzipData = [ANSGzip ungzipData:decodBase64Data];
                          if (unzipData) {
                              //  base64解密 -> 解压
                              responseDict = [NSJSONSerialization JSONObjectWithData:unzipData options:NSJSONReadingAllowFragments error:&error];
                          } else {
                              AnsDebug(@"Data parsing failed!");
                              AgentUnlock()
                              return ;
                          }
                      }
                      if (error) {
                          AnsDebug(@"Server response unzip error!");
                          AgentUnlock()
                          return ;
                      }
                      if ([responseDict[@"code"] integerValue] == 200) {
                          uploadStatus = YES;
                          AgentUnlock()
                          return;
                      }
                      if ([responseDict[@"code"] integerValue] == 400 ||
                          [responseDict[@"code"] integerValue] == 4200) {
                          ANSBriefWarning(@"%@", responseDict);
                          uploadStatus = YES;
                          AgentUnlock()
                          return;
                      }
                      if ([responseDict[@"code"] integerValue] == 500) {
                          id policyInfo = responseDict[@"policy"];
                          if ([policyInfo isKindOfClass:[NSDictionary class]]) {
                              dispatch_block_t block = ^(){
                                  [ANSStrategyManager saveServerStrategyInfo:policyInfo];
                              };
                              [self dispatchOnSerialQueue:block];
                          }
                      }
                      ANSConsoleLog *checkResult = [[ANSConsoleLog alloc] init];
                      checkResult.remarks = [NSString stringWithFormat:@"Send message failed. \nreason: %@",responseDict];
                      ANSBriefWarning(@"%@",[checkResult messageDisplay]);
                      AgentUnlock()
                  } @catch (NSException *exception) {
                      AnsDebug(@"PostRequest exception: %@", exception);
                      AgentUnlock()
                  }
              } failure:^(NSError *error) {
                  ANSConsoleLog *checkResult = [[ANSConsoleLog alloc] init];
                  checkResult.remarks = [NSString stringWithFormat:@"Send message failed. reason: %@",error.description];
                  ANSBriefWarning(@"%@",[checkResult messageDisplay]);
                  AgentUnlock()
                  return ;
              }];
            AgentLock()
            return uploadStatus;
        } @catch (NSException *exception) {
            AnsDebug(@"UploadBlock exception: %@", exception);
            AgentUnlock()
        }
    };
    
    dispatch_async(self->_requestQueue, ^{
        [self uploadDataWithType:@"" limitCount:100 block:uploadBlock];
    });
}

/** 获取本地上传数据并回调 */
- (void)uploadDataWithType:(NSString *)type limitCount:(NSInteger)dataCount block:(BOOL (^)(NSString*, NSDictionary*, NSString*))uploadBlock {
    BOOL shouldUploadAgain = YES;
    @try {
        if (!uploadBlock) {
            [_isSendingDataLock lock];
            isSendingData = NO;
            [_isSendingDataLock unlock];
            return;
        }
        
        ANSConsoleLog *checkResult = [[ANSConsoleLog alloc] init];
        
        __block NSString *blockServerUrl = nil;
        __block NSString *blockUploadData = nil ;
        __block NSDictionary *blockHttpHeader = nil;
        
        dispatch_sync(self->_serialQueue, ^{
            blockServerUrl = [[[ANSStrategyManager sharedManager] currentUrl] copy];
        });
        if (blockServerUrl == nil || blockServerUrl.length == 0) {
            checkResult.remarks = @"Please set uploadURL";
            ANSBriefWarning(@"%@",[checkResult messageDisplay]);
            [_isSendingDataLock lock];
            isSendingData = NO;
            [_isSendingDataLock unlock];
            return;
        }
        
        __block NSArray *dataArray = nil;
        dispatch_sync(self->_serialQueue, ^{
            dataArray = [self->_dbHelper getTopRecords:dataCount type:type];
            if (dataArray.count > 0) {
                dataArray = [[ANSTimeCheckManager shared] checkDataArray:dataArray];
                blockHttpHeader = [ANSEncryptUtis httpHeaderInfo];
                NSString *jsonString = [NSString stringWithFormat:@"[%@]",[dataArray componentsJoinedByString:@","]];
                blockUploadData = [[ANSEncryptUtis processUploadBody:jsonString param:blockHttpHeader] copy];
                checkResult.remarks = [NSString stringWithFormat:@"Send message to server: %@ \ndata:\n%@\n", blockServerUrl, jsonString];
                ANSBriefLog(@"%@",[checkResult messageDisplay]);
            }
        });
        
        if (dataArray == nil || dataArray.count == 0) {
            [_isSendingDataLock lock];
            isSendingData = NO;
            [_isSendingDataLock unlock];
            return;
        }
        
        if (uploadBlock(blockServerUrl, blockHttpHeader, blockUploadData)) {
            checkResult.remarks = @"Send message success";
            
            __block BOOL cleanResult = NO;
            dispatch_sync(self->_serialQueue, ^{
                ANSBriefLog(@"%@",[checkResult messageDisplay]);
                [[ANSStrategyManager sharedManager] resetDelayStrategyFailedTry];
                cleanResult = [self->_dbHelper deleteUploadRecordsWithType:type];
            });
            if (!cleanResult) {
                AnsDebug(@"Database delete error!");
                shouldUploadAgain = NO;
            }
        } else {
            dispatch_sync(self->_serialQueue, ^{
                [self->_dbHelper resetUploadRecordsWithType:type];
                [[ANSStrategyManager sharedManager] increaseDelayStrategyFailCount];
            });
            shouldUploadAgain = NO;
        }
        
    } @catch (NSException *exception) {
        AnsDebug(@"Database query exception: %@", exception);
        shouldUploadAgain = NO;
    }
    [_isSendingDataLock lock];
    isSendingData = NO;
    [_isSendingDataLock unlock];
    
    if (shouldUploadAgain) {
        dispatch_async(self->_serialQueue, ^{
            [self flushDataIfIgnorePolicy:NO];
        });
    }
}

#pragma mark - other

/** app首次启动时间 */
- (NSString *)appFirstStartTime {
    NSString *launchDate = [ANSFileManager userDefaultValueWithKey:ANSAppLaunchDate];
    if (!launchDate) {
        launchDate = [[ANSDateUtil dateFormat] stringFromDate:[NSDate date]];
        [ANSFileManager saveUserDefaultWithKey:ANSAppLaunchDate value:launchDate];
    }
    return launchDate;
}

- (BOOL)isIgnoreTrackWithClassName:(NSString *)className {
    [_propertiesLock lock];
    BOOL retValue = [_ignoredViewControllers containsObject:className];
    [_propertiesLock unlock];
    return retValue;
}

- (NSNumber *)appDuration {
    long long duration = _appResignActiveTime - _appBecomeActiveTime;
    return [NSNumber numberWithLongLong:duration];
}

- (NSString *)getXwho {
    return [self.userId copy];
}

/** 更新用户标识 */
- (void)updateUserId {
    NSDictionary *properties = [self.commonProperties copy];
    NSString *aliasID = properties[ANSEventAlias];
    NSString *anonymousId = properties[ANSAnonymousId];
    NSString *xwho;
    if (aliasID.length > 0) {
        xwho = aliasID;
    } else if (anonymousId.length > 0) {
        xwho = anonymousId;
    } else {
        xwho = properties[ANSUUID];
    }
    self.userId = xwho;
}

+ (NSLock *)getUserDefaultLock {
    return [AnalysysSDK sharedManager]->_userDefaultsLock;
}

@end
