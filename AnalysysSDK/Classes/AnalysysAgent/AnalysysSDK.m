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
#import "ANSLock.h"
#import "ANSQueue.h"
#import "ANSDataCheckLog.h"
#import "AnalysysLogger.h"

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

#import "ANSUncaughtExceptionHandler.h"
#import "ANSTimeCheckManager.h"

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

@interface AnalysysSDK () {
    
}

@property (nonatomic, strong) NSDictionary *commonProperties;  // 自定义常用属性
@property (nonatomic, strong) NSDictionary *superProperties;   // 用户通用属性
@property (nonatomic, copy) NSString *userId;  //  当前用户

@end


@implementation AnalysysSDK {
    ANSUploadManager *_uploadManager;
    ANSDatabase *_dbHelper;
    NSMutableSet *_pageViewBlackList;    //  忽略自动采集的页面
    NSMutableSet *_pageViewWhiteList;  //  只采集某些页面
    BOOL _isAppLaunched;    // 是否launch启动，防止pageview事件先于start事件
    BOOL _canSendProfileSetOnce;    // 是否可发送profileSetOnce
    BOOL _canSendAutoInstallation;  // 是否可发送渠道追踪
    BOOL _isAutoCollectionPage; // 页面自动采集
    BOOL _isSDKInit;    //  是否调用SDK初始化
    NSInteger _maxCacheSize;    // 本地允许最大缓存
    long long _appBecomeActiveTime; // App活跃点
    
    AnalysysNetworkType _uploadNetworkType;

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
        _isBackgroundActive = NO;
        _isAutoCollectionPage = YES;
        _maxCacheSize = 10000;
        _pageViewBlackList = [NSMutableSet set];
        _pageViewWhiteList = [NSMutableSet set];
        _appBecomeActiveTime = [ANSUtil nowTimeMilliseconds];
        _isSendingDataLock = [[NSLock alloc] init];
        _uploadNetworkType = AnalysysNetworkWWAN | AnalysysNetworkWIFI;
        
        ANSPropertyLock();
        _superProperties = [ANSFileManager unarchiveSuperProperties];
        _commonProperties = [ANSFileManager unarchiveCommonProperties];
        ANSPropertyUnlock();
        
        [self updateUserId];
        
        [[ANSTelephonyNetwork shareInstance] startReachability];
        
        [self registNotifications];
        
        _dbHelper = [[ANSDatabase alloc] initWithDatabaseName:@"ANALYSYS.db"];
        
        [_dbHelper resetLogStatus];
    }
    return self;
}

/**
注册事件监听对象

@param observerListener 事件监听对象
*/
- (void)setObserverListener:(id)observerListener {
    self.delegate = (id<EventDataDelegate>)observerListener;
    NSString *userId = [self getXwho];
    // EA xwho 回传
    if (self.delegate && [self.delegate respondsToSelector:@selector(onUserProfile:value:)]) {
        [self.delegate onUserProfile:@"xwho" value:userId];
    }
}

- (void)startWithConfig:(AnalysysAgentConfig *)config {
    @try {
        static dispatch_once_t autoTrackOnceToken ;
        dispatch_once(&autoTrackOnceToken, ^{
            if (config.autoTrackCrash) {
                ANSInstallUncaughtExceptionHandler();
            }
            [ANSOpenURLAutoTrack autoTrack];
            [ANSPageAutoTrack autoTrack];
        });
        
        NSString *upServerUrl;
        if (config.baseUrl.length > 0) {
            upServerUrl = [NSString stringWithFormat:@"https://%@:%@/up", config.baseUrl, ANSHttpsDefaultPort];
            
            //  可视化模块
            [ANSModuleProcessing setVisualBaseUrl:config.baseUrl];
        }
        
        [self appFirstLauchDate];
        
        if ([self isAppKeyChanged:config.appKey] ||
            [self isServerURLChanged:upServerUrl]) {
            [self profileResetWithType:ANSStartReset];
        }
        
        _isSDKInit = YES;
        NSLog(@"\n\n----------------------- [Analysys] [Log] ----------------------- \
              \n------ Init iOS Analysys OC SDK Success. Version: %@ ------ \
              \n----------------------------------------------------------------",ANSSDKVersion);
        
        [self trackAppStartEvent];
    } @catch (NSException *exception) {
        ANSDebug(@"SDK init exception: %@", exception);
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
    if (![self isSDKInitBeforeInterface:@"setUploadURL"]) {
        return;
    }
    ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
    checkResult.value = uploadURL;
    
    NSString *url = [ANSUtil getHttpUrlString:uploadURL];
    if (url.length == 0) {
        [[ANSStrategyManager sharedManager] setUserServerUrlValue:nil];
        
        checkResult.resultType = AnalysysResultSetFailed;
        checkResult.remarks = @"'uploadURL' must start with 'http://' or 'https://'";
        ANSBriefWarning(@"%@",[checkResult messageDisplay]);
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
}

/** 设置可视化websocket服务器地址 */
- (void)setVisitorDebugURL:(NSString *)visitorDebugURL {
    if (![self isSDKInitBeforeInterface:@"setVisitorDebugURL"]) {
        return;
    }
    [ANSModuleProcessing setVisitorDebugURL:visitorDebugURL];
}

/** 设置线上请求埋点配置的服务器地址 */
- (void)setVisitorConfigURL:(NSString *)configURL {
    if (![self isSDKInitBeforeInterface:@"setVisitorConfigURL"]) {
        return;
    }
    [ANSModuleProcessing setVisualConfigUrl:configURL];
}


#pragma mark - SDK发送策略

/** debug模式 */
- (void)setDebugMode:(AnalysysDebugMode)debugMode {
    switch (debugMode) {
        case AnalysysDebugOff:
            [AnalysysLogger sharedInstance].logMode = AnalysysLogOff;
            break;
        case AnalysysDebugOnly:
            [AnalysysLogger sharedInstance].logMode = AnalysysLogOn;
            break;
        case AnalysysDebugButTrack: {
            [AnalysysLogger sharedInstance].logMode = AnalysysLogOn;
            if ([self isDebugModeChanged:debugMode]) {
                [self profileResetWithType:ANSStartReset];
            }
            ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
            checkResult.resultType = AnalysysResultSetSuccess;
            checkResult.value = [NSNumber numberWithInteger:debugMode];
            ANSLog(@"%@",[checkResult messageDisplay]);
        }
            break;
        default:
            break;
    }
}

/** 当前调试模式 */
- (AnalysysDebugMode)debugMode {
    AnalysysDebugMode debugMode = [ANSStrategyManager sharedManager].currentUseDebugMode;
    return debugMode;
}

/** 设置上传间隔时间 */
- (void)setIntervalTime:(NSInteger)flushInterval {
    ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
    checkResult.value = [NSNumber numberWithInteger:flushInterval];
    if (flushInterval <= 1) {
        checkResult.resultType = AnalysysResultSetFailed;
        checkResult.remarks = @"flushInterval must be > 1";
    } else {
        checkResult.resultType = AnalysysResultSetSuccess;
        [[ANSStrategyManager sharedManager] setUserIntervalTimeValue:flushInterval];
    }
    ANSLog(@"%@",[checkResult messageDisplay]);
}

/** 数据累积"size"条数后触发上传 */
- (void)setMaxEventSize:(NSInteger)flushSize {
    ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
    checkResult.value = [NSNumber numberWithInteger:flushSize];
    if (flushSize <= 1) {
        checkResult.resultType = AnalysysResultSetFailed;
        checkResult.remarks = @"flushSize must be > 1";
    } else {
        checkResult.resultType = AnalysysResultSetSuccess;
        [[ANSStrategyManager sharedManager] setUserMaxEventSizeValue:flushSize];
    }
    ANSLog(@"%@",[checkResult messageDisplay]);
}

/** 本地缓存上限值 */
- (void)setMaxCacheSize:(NSInteger)cacheSize {
    ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
    checkResult.value = [NSNumber numberWithInteger:cacheSize];
    if (cacheSize < 100 || cacheSize > 10000) {
        checkResult.resultType = AnalysysResultSetFailed;
        checkResult.remarks = @"cacheSize must be >= 100 and <= 10000,otherwise use default";
    } else {
        checkResult.resultType = AnalysysResultSetSuccess;
        checkResult.value = [NSNumber numberWithInteger:cacheSize];
        _maxCacheSize = cacheSize;
    }
    ANSLog(@"%@",[checkResult messageDisplay]);
}

/** 获取当前设置的本地最大存储 */
- (NSInteger)maxCacheSize {
    return _maxCacheSize;
}

/** 主动向服务器上传数据 */
- (void)flush {
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:^{
         [self flushDataIfIgnorePolicy:YES];
    }];
}
    
- (void)setUploadNetworkType:(AnalysysNetworkType)networkType {
    @synchronized (self) {
        _uploadNetworkType = networkType;
    }
}

- (void)cleanDBCache {
    [_dbHelper cleanDBCache];
}

#pragma mark - 事件

/** 添加事件及附加属性 */
- (void)track:(NSString *)event properties:(NSDictionary *)properties {
    if (![self isSDKInitBeforeInterface:@"track"]) {
        return;
    }
    NSDictionary *tProperties = [properties mutableCopy];
    dispatch_block_t block = ^(){
        ANSDataCheckLog *checkResult = [ANSDataCheckRouter checkEvent:event];
        if (checkResult) {
            ANSBriefWarning(@"%@",[checkResult messageDisplay]);
        }
        
        NSDictionary *trackInfo = [ANSDataProcessing processTrack:(event ?: @"") properties:tProperties];
        [self saveUploadInfo:trackInfo event:ANSEventTrack handler:^{}];
    };
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:block];
}

#pragma mark - 页面事件

/** 页面跟踪及附加属性 */
- (void)pageView:(NSString *)pageName properties:(NSDictionary *)properties {
    if (![self isSDKInitBeforeInterface:@"pageView"]) {
        return;
    }
    if (![pageName isKindOfClass:NSString.class]) {
        pageName = nil;
        ANSBriefWarning(@"pagename is not <NSString>.");
    } else if ([pageName isKindOfClass:NSString.class] && pageName.length == 0) {
        pageName = nil;
        ANSBriefWarning(@"pagename is empty.");
    }
    [self trackPageView:pageName properties:properties];
}

/** SDK页面自动采集 */
- (void)autoPageView:(NSString *)pageName properties:(NSDictionary *)properties {
    [self trackPageView:pageName properties:properties];
}

/** 设置是否允许页面自动采集 */
- (void)setAutomaticCollection:(BOOL)isAuto {
    ANSPropertyLock();
    _isAutoCollectionPage = isAuto;
    ANSPropertyUnlock();
}

/** 当前SDK是否允许页面自动跟踪 */
- (BOOL)isViewAutoTrack {
    ANSPropertyLock();
    BOOL retValue = _isAutoCollectionPage;
    ANSPropertyUnlock();
    return retValue;
}

/** 只采集部分页面 */
- (void)setPageViewWhiteListByPages:(NSSet<NSString *> *)controllers {
    if (controllers.count == 0 || ![controllers isKindOfClass:NSSet.class]) {
        return;
    }
    NSSet *sControllers = [controllers mutableCopy];
    ANSPropertyLock();
    [_pageViewWhiteList setSet:sControllers];
    
    ANSPropertyUnlock();
}

/** 忽略部分页面自动采集 */
- (void)setPageViewBlackListByPages:(NSSet<NSString *> *)controllers {
    if (controllers.count == 0 || ![controllers isKindOfClass:NSSet.class]) {
        return;
    }
    NSSet *sControllers = [controllers mutableCopy];
    ANSPropertyLock();
    [_pageViewBlackList setSet:sControllers];
    ANSPropertyUnlock();
}

/** 忽略部分页面自动采集 */
- (void)setIgnoredAutomaticCollectionControllers:(NSArray<NSString *> *)controllers {
    if (controllers.count == 0 || ![controllers isKindOfClass:NSArray.class]) {
        return;
    }
    NSSet *sets = [NSSet setWithArray:controllers];
    [self setPageViewBlackListByPages:sets];
}

#pragma mark - 热图模块儿接口

/** 是否采集热图坐标 */
- (void)setAutomaticHeatmap:(BOOL)autoTrack {
    [ANSHeatMapAutoTrack heatMapAutoTrack:autoTrack];
}

- (void)setHeatmapIgnoreAutoClickByPage:(NSSet<NSString *> *)controllerNames {
    if (controllerNames.count == 0 || ![controllerNames isKindOfClass:NSSet.class]) {
        return;
    }
    NSSet *sControllers = [controllerNames mutableCopy];
    ANSPropertyLock();
    [[ANSHeatMapAutoTrack sharedManager].ignoreAutoClickPage setSet:sControllers];
    ANSPropertyUnlock();
}

- (void)setHeatmapAutoClickByPage:(NSSet<NSString *> *)controllerNames {
    if (controllerNames.count == 0 || ![controllerNames isKindOfClass:NSSet.class]) {
        return;
    }
    NSSet *sControllers = [controllerNames mutableCopy];
    ANSPropertyLock();
    [[ANSHeatMapAutoTrack sharedManager].autoClickPage setSet:sControllers];
    ANSPropertyUnlock();
}

#pragma mark - 通用属性

/** 注册通用属性 */
- (void)registerSuperProperties:(NSDictionary *)superProperties {
    ANSDataCheckLog *checkResult = [ANSDataCheckRouter checkSuperProperties:&superProperties];
    if (checkResult && checkResult.resultType <= AnalysysResultSuccess) {
        ANSBriefWarning(@"%@",[checkResult messageDisplay]);
        if (superProperties == nil) {
            return;
        }
    }
    ANSPropertyLock();
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:_superProperties];
    [tmp addEntriesFromDictionary:superProperties];
    _superProperties = [NSDictionary dictionaryWithDictionary:tmp];
    BOOL result = [ANSFileManager archiveSuperProperties:_superProperties];
    ANSPropertyUnlock();
    if (result) {
        ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultSetSuccess;
        ANSLog(@"%@",[checkResult messageDisplay]);
    } else {
        ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultSetFailed;
        ANSBriefWarning(@"%@",[checkResult messageDisplay]);
    }
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
    ANSPropertyLock();
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
    [tmp removeObjectForKey:superPropertyName];
    self.superProperties = [NSDictionary dictionaryWithDictionary:tmp];
    BOOL result = [ANSFileManager archiveSuperProperties:self.superProperties];
    ANSPropertyUnlock();
    if (result) {
        ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.value = superPropertyName;
        checkResult.resultType = AnalysysResultSetSuccess;
        ANSLog(@"%@",[checkResult messageDisplay]);
    }
}

/** 清除所有通用属性 */
- (void)clearSuperProperties {
    ANSPropertyLock();
    self.superProperties = [NSDictionary dictionary];
    BOOL result = [ANSFileManager archiveSuperProperties:self.superProperties];
    ANSPropertyUnlock();
    if (result) {
        ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultSetSuccess;
        ANSLog(@"%@",[checkResult messageDisplay]);
    }
}

/** 获取hybird通用属性，取App与js集合，且已App为准 */
- (NSDictionary *)getSuperPropertiesValue {
    ANSPropertyLock();
    NSDictionary *hybirdSuperProperty = [ANSFileManager unarchiveHybridSuperProperties];
    NSMutableDictionary *superProperties = [NSMutableDictionary dictionaryWithDictionary:hybirdSuperProperty];
    [superProperties addEntriesFromDictionary:_superProperties];
    ANSPropertyUnlock();
    return [superProperties copy];
}

/** 获取hybird某个通用属性，取App与js合集，若key相同则以App为准 */
- (id)getSuperProperty:(NSString *)superPropertyName {
    NSDictionary *superProperties = [self getSuperPropertiesValue];
    id retValue = superProperties[superPropertyName];
    return retValue;
}

/** 普通属性 */
- (NSDictionary *)getCommonProperties {
    ANSPropertyLock();
    NSDictionary *retValue = [_commonProperties copy];
    ANSPropertyUnlock();
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
    
    NSString *firstLaunchDate = [self appFirstLauchDate];
    [presetProperties setValue:(firstLaunchDate ?: @"") forKey:ANSPresetFirstVisitTime];
    
    if (_isSDKInit) {
        NSString *session = [[ANSSession shareInstance] localSession];
        [presetProperties setValue:session forKey:ANSPresetSessionId];
    } else {
        [presetProperties setValue:@"" forKey:ANSPresetSessionId];
    }
    
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
    ANSDataCheckLog *checkResult = [ANSDataCheckRouter checkLengthOfIdentify:anonymousId];
    if (checkResult && checkResult.resultType < AnalysysResultSuccess) {
        ANSBriefWarning(@"%@",[checkResult messageDisplay]);
        return;
    }
    ANSPropertyLock();
    NSMutableDictionary *tmpCommonProperties = [NSMutableDictionary dictionaryWithDictionary:_commonProperties];
    [tmpCommonProperties setValue:anonymousId forKey:ANSAnonymousId];
    _commonProperties = [NSDictionary dictionaryWithDictionary:tmpCommonProperties];
    BOOL result = [ANSFileManager archiveCommonProperties:_commonProperties];
    ANSPropertyUnlock();
    
    [self updateUserId];
    
    if (result) {
        ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.value = anonymousId;
        checkResult.resultType = AnalysysResultSetSuccess;
        ANSLog(@"%@",[checkResult messageDisplay]);
    }
}

/** 用户关联 */
- (void)alias:(NSString *)aliasId originalId:(NSString *)originalId {
    if (![self isSDKInitBeforeInterface:@"alias"]) {
        return;
    }
    dispatch_block_t block = ^(){
        ANSDataCheckLog *checkResult = [ANSDataCheckRouter checkLengthOfAliasId:aliasId];
        if (checkResult) {
            ANSBriefWarning(@"%@",[checkResult messageDisplay]);
            return ;
        }
        checkResult = [ANSDataCheckRouter checkAliasOriginalId:originalId];
        if (checkResult) {
            ANSBriefWarning(@"%@",[checkResult messageDisplay]);
            return ;
        }
        ANSPropertyLock();
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
        ANSPropertyUnlock();
        NSDictionary *aliasInfo = [ANSDataProcessing processAliasSDKProperties:properties];
        [self saveUploadInfo:aliasInfo event:ANSEventAlias handler:^{}];
        [self upProfileSetOnce];
    };
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:block];
    // EA xwho 回传
    if (self.delegate && [self.delegate respondsToSelector:@selector(onUserProfile:value:)]) {
        [self.delegate onUserProfile:@"xwho" value:aliasId];
    }
}

- (NSString *)getDistinctIdInternal {
    ANSPropertyLock();
    NSString *anonymousId = self.commonProperties[ANSAnonymousId];
    NSString *distictId;
    if (anonymousId.length > 0) {
        distictId = anonymousId;
    } else {
        distictId = self.commonProperties[ANSUUID];
        if (!distictId) {
            distictId = [[NSUUID UUID] UUIDString];

            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.commonProperties];
            dic[ANSUUID] = distictId;
            self.commonProperties = [NSDictionary dictionaryWithDictionary:dic];
            [ANSFileManager archiveCommonProperties:self.commonProperties];
        }
    }
    ANSPropertyUnlock();
    return distictId;
}

/** 获取用户的匿名ID*/
- (NSString *)getDistinctId {
    NSString * returnedDistinctId = [self getDistinctIdInternal];
    return returnedDistinctId;
}

/** 设置用户属性 */
- (void)profileSet:(NSDictionary *)property {
    if (![self isSDKInitBeforeInterface:@"profileSet"]) {
        return;
    }
    NSDictionary *sProperties = [property mutableCopy];
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:^{
        NSDictionary *upInfo = [ANSDataProcessing processProfileSetProperties:sProperties];
        [self saveUploadInfo:upInfo event:ANSEventProfileSet handler:^{}];
    }];
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
    if (![self isSDKInitBeforeInterface:@"profileSetOnce"]) {
        return;
    }
    NSDictionary *sProperties = [property mutableCopy];
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:^{
        NSDictionary *upInfo = [ANSDataProcessing processProfileSetOnceProperties:sProperties SDKProperties:nil];
        [self saveUploadInfo:upInfo event:ANSEventProfileSetOnce handler:^{}];
    }];
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
    if (![self isSDKInitBeforeInterface:@"profileIncrement"]) {
        return;
    }
    __block NSDictionary *blockProperty = [property mutableCopy];
    dispatch_block_t block = ^(){
        ANSDataCheckLog *checkResult = [ANSDataCheckRouter checkIncrementProperties:&blockProperty];
        if (checkResult && checkResult.resultType < AnalysysResultSuccess) {
            ANSBriefWarning(@"%@",[checkResult messageDisplay]);
        }
        
        NSDictionary *upInfo = [ANSDataProcessing processProfileIncrementProperties:blockProperty];
        [self saveUploadInfo:upInfo event:ANSEventProfileIncrement handler:^{}];
    };
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:block];
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
    if (![self isSDKInitBeforeInterface:@"profileAppend"]) {
        return;
    }
    __block NSDictionary *blockProperty = [property mutableCopy];
    dispatch_block_t block = ^(){
        ANSDataCheckLog *checkResult = nil;
        checkResult = [ANSDataCheckRouter checkAppendProperties:&blockProperty];
        if (checkResult && checkResult.resultType < AnalysysResultSuccess) {
            ANSBriefWarning(@"%@",[checkResult messageDisplay]);
        }
        
        NSDictionary *upInfo = [ANSDataProcessing processProfileAppendProperties:blockProperty];
        [self saveUploadInfo:upInfo event:ANSEventProfileAppend handler:^{}];
    };
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:block];
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
    if (![self isSDKInitBeforeInterface:@"profileUnset"]) {
        return;
    }
    if (propertyName.length == 0) {
        return;
    }
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:^{
        NSDictionary *upInfo = [ANSDataProcessing processProfileUnsetWithSDKProperties:@{propertyName: @""}];
        [self saveUploadInfo:upInfo event:ANSEventProfileUnset handler:^{}];
    }];
}

/** 删除当前用户的所有属性 */
- (void)profileDelete {
    if (![self isSDKInitBeforeInterface:@"profileDelete"]) {
        return;
    }
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:^{
        NSDictionary *upInfo = [ANSDataProcessing processProfileDelete];
        [self saveUploadInfo:upInfo event:ANSEventProfileDelete handler:^{}];
    }];
}

#pragma mark - 清除本地设置

/** 清除本地设置 */
- (void)reset {
    if (![self isSDKInitBeforeInterface:@"reset"]) {
        return;
    }
    [self profileResetWithType:ANSProfileReset];
    [self sendResetInfo];
}

#pragma mark - Hybrid 页面

/** WKWebView统计 */
- (BOOL)setHybridModel:(id)webView request:(NSURLRequest *)request {
    if (webView == nil) {
        return NO;
    }
    @try {
        return [ANSHybrid excuteRequest:request webView:webView];
    } @catch (NSException *exception) {
        ANSBriefError(@"Hyrbrid error:%@!", exception.description);
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
            case AnalysysPushALi:
                [pushDic setValue:pushID forKey:@"$ALIYUN"];
                break;
            default:
                break;
        }
        NSDictionary *upInfo = [ANSDataProcessing processProfileSetProperties:pushDic];
        [self saveUploadInfo:upInfo event:ANSEventPush handler:^{}];
    };
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:block];
}

/** 追踪活动推广，可回调用户自定义信息 */
- (void)trackCampaign:(id)userInfo isClick:(BOOL)isClick userCallback:(void(^ _Nullable )(id campaignInfo))userCallback {
    if (userInfo == nil) {
        return;
    }
    NSDictionary *analysysPushInfo = [ANSModuleProcessing parsePushInfo:userInfo];
    if (analysysPushInfo) {
        if (userCallback) {
            userCallback(analysysPushInfo);
        }
        //  防止App活着时，收到推送消息处理早于start事件
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [self handlePushInfo:analysysPushInfo isClick:isClick];
        } else {
            [ANSQueue dispatchAfterSeconds:1.0 onLogSerialQueueWithBlock:^{
                [self handlePushInfo:analysysPushInfo isClick:isClick];
            }];
        }
    }
}

/** 处理推送通知 */
- (void)handlePushInfo:(NSDictionary *)analysysPushInfo isClick:(BOOL)isClick {
    NSDictionary *contextProperty = [ANSModuleProcessing parsePushContext:analysysPushInfo];
    if (!contextProperty) {
        return;
    }
    
    dispatch_block_t block = ^(){
        NSDictionary *pushReceiverInfo = [ANSDataProcessing processSDKEvent:@"$push_receiver_success" properties:contextProperty];
        
        [self saveUploadInfo:pushReceiverInfo event:ANSEventPush handler:^{}];
        
        if (isClick) {
            NSDictionary *pushClickInfo = [ANSDataProcessing processSDKEvent:@"$push_click" properties:contextProperty];
            [self saveUploadInfo:pushClickInfo event:ANSEventPush handler:^{}];
            
            [ANSModuleProcessing pushClickParameter:analysysPushInfo];
            
            NSDictionary *pushProcessInfo = [ANSDataProcessing processSDKEvent:@"$push_process_success" properties:contextProperty];
            [self saveUploadInfo:pushProcessInfo event:ANSEventPush handler:^{}];
        }
    };
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:block];
    
}

#pragma mark - --------- private method ---------

#pragma mark - 热图

- (void)trackHeatMapWithSDKProperties:(NSDictionary *)sdkProperties  {
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:^{
        NSDictionary *heatMap = [ANSDataProcessing processHeatMapWithSDKProperties:sdkProperties];
        [self saveUploadInfo:heatMap event:ANSEventHeatMap handler:^{}];
    }];
}

#pragma mark - 重要信息改变

/** appKey是否更改 */
- (BOOL)isAppKeyChanged:(NSString *)appKey {
    NSString *lastAppKey = [ANSFileManager userDefaultValueWithKey:ANSAppKey];
    [ANSFileManager saveUserDefaultWithKey:ANSAppKey value:appKey];
    
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
        [self trackAppStartEvent];
        [ANSPageAutoTrack autoTrackLastVisitPage];
    }
    _isAppLaunched = NO;
}

/** app变为非活跃状态 */
- (void)applicationWillResignActiveNotification:(NSNotification *)notification {
    _isAppLaunched = NO;
    _isBackgroundActive = YES;
    _appDuration = [ANSUtil nowTimeMilliseconds] - _appBecomeActiveTime;
    
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:^{
        [[ANSSession shareInstance] updatePageDisappearDate];
        
        NSDictionary *endEvent = [ANSDataProcessing processAppEnd];
        [self saveUploadInfo:endEvent event:ANSEventAppEnd handler:^{}];
    }];
}

/** 数据上传 */
- (void)flushDataNotification:(NSNotification *)notification {
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:^{
        [self flushDataIfIgnorePolicy:NO];
    }];
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
            ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
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
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:block];
}

/** 页面数据 */
- (void)trackPageView:(NSString *)pageName properties:(NSDictionary *)properties {
    dispatch_block_t block = ^(){
        NSMutableDictionary *pageProperties = [NSMutableDictionary dictionary];
        [pageProperties setValue:pageName forKey:ANSPageTitle];
        if ([properties isKindOfClass:[NSDictionary class]]) {
            [pageProperties addEntriesFromDictionary:properties];
         } else if (properties) {
            pageProperties = properties;
        }
        NSDictionary *pageInfo = [ANSDataProcessing processPageProperties:pageProperties SDKProperties:nil];
        
        [self saveUploadInfo:pageInfo event:ANSEventPageView handler:^{}];
    };
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:block];
}

/** 上传一次 set_once 数据 */
- (void)upProfileSetOnce {
    if (AnalysysConfig.autoProfile) {
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        NSString *firstLaunchDate = [self appFirstLauchDate];
        if (!firstLaunchDate) {
            firstLaunchDate = [self resetFirstLaunchDate];
        }
        properties[ANSPresetFirstVisitTime] = firstLaunchDate;
        properties[ANSPresetFirstVisitLanguage] = [ANSDeviceInfo getDeviceLanguage];
        
        NSDictionary *setOnce = [ANSDataProcessing processProfileSetOnceProperties:nil SDKProperties:properties];
        [self saveUploadInfo:setOnce event:ANSEventProfileSetOnce handler:^{}];
    }
}

/** 渠道追踪 */
- (void)upFirstInstallation {
    if (_canSendAutoInstallation && AnalysysConfig.autoInstallation) {
        _canSendAutoInstallation = NO;
        NSDictionary *utm = [ANSOpenURLAutoTrack utmParameters];
        NSDictionary *attribute = [ANSDataProcessing processInstallationSDKProperties:utm];
        [self saveUploadInfo:attribute event:ANSEventInstallation handler:^{}];
    }
}

/** 重置本地缓存 */
- (void)profileResetWithType:(ANSResetType)resetType {
    ANSPropertyLock();
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:_commonProperties];
    if (resetType == ANSProfileReset) {
        [tmp setValue:[[NSUUID UUID] UUIDString] forKey:ANSUUID];
    }
    _canSendProfileSetOnce = YES;
    [tmp removeObjectForKey:ANSAnonymousId];
    [tmp removeObjectForKey:ANSEventAlias];
    [tmp removeObjectForKey:ANSOriginalId];
    _superProperties = [NSDictionary dictionary];
    [ANSFileManager archiveSuperProperties:_superProperties];
    _commonProperties = tmp;
    [ANSFileManager archiveCommonProperties:_commonProperties];
    ANSPropertyUnlock();
    
    [self updateUserId];
    
    [[ANSSession shareInstance] resetSession];
    
    [[ANSStrategyManager sharedManager] resetStrategy];
    
    [ANSFileManager saveUserDefaultWithKey:ANSAppLaunchDate value:nil];
    
    [_dbHelper cleanDBCache];
}

/** 发送reset事件 */
- (void)sendResetInfo {
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:^{
        if (AnalysysConfig.autoProfile) {
            ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
            checkResult.remarks = @"send reset info.";
            ANSBriefLog(@"%@",[checkResult messageDisplay]);
            
            NSString *dateStr = [[ANSDateUtil dateFormat] stringFromDate:[NSDate date]];
            NSDictionary *upInfo = [ANSDataProcessing processProfileSetOnceProperties:nil SDKProperties:@{ANSPresetResetTime: dateStr}];
            [self saveUploadInfo:upInfo event:ANSEventProfileSetOnce handler:^{}];
        }
    }];
}

#pragma mark - 数据存储及上传

/** 重新获取首次启动时间 */
- (NSString *)resetFirstLaunchDate {
    NSString *firstStartDate = [ANSFileManager userDefaultValueWithKey:ANSAppLaunchDate];
    if (!firstStartDate) {
        firstStartDate = [[ANSDateUtil dateFormat] stringFromDate:[NSDate date]];
        [ANSFileManager saveUserDefaultWithKey:ANSAppLaunchDate value:firstStartDate];
    }
    return firstStartDate;
}

/** 首次启动 */
- (NSString *)appFirstLauchDate {
    NSString *launchDate = [ANSFileManager userDefaultValueWithKey:ANSAppLaunchDate];
    if (!launchDate) {
        _canSendProfileSetOnce = YES;
        _canSendAutoInstallation = YES;
        ANSPropertyLock();
        NSString *uuid = self.commonProperties[ANSUUID];
        if (!uuid) {
            NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:_commonProperties];
            [tmp setValue:[[NSUUID UUID] UUIDString] forKey:ANSUUID];
            self.commonProperties = tmp;
        }
        [ANSFileManager archiveCommonProperties:self.commonProperties];
        ANSPropertyUnlock();
        
        [self updateUserId];
    }
    return launchDate;
}

/** 数据存储 */
- (void)saveUploadInfo:(NSDictionary *)dataInfo event:(NSString *)event handler:(void(^)(void))handler {
    if (!dataInfo) {
        return;
    }
    
    // EA 事件回传
    if (self.delegate && [self.delegate respondsToSelector:@selector(onEventDataReceived:)]) {
        [self.delegate onEventDataReceived:dataInfo];
    }
    
    [_dbHelper insertRecordObject:dataInfo event:event maxCacheSize:_maxCacheSize result:^(BOOL success) {
        if (success) {
            if (handler) {
                handler();
            }
            [self uploadDataType:event];
        }
    }];
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
    AnalysysNetworkType networkType = [self currentNetworkType];
    if (AnalysysNetworkNONE == networkType) {
        ANSBriefWarning(@"Please check the network status");
        return;
    }
    
    if (![[ANSTimeCheckManager shared] timeCheckRequestIsFinished]) {
        return;
    }
    
    if (!(networkType & _uploadNetworkType)) {
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
                              ANSDebug(@"Data parsing failed!");
                              AgentUnlock()
                              return ;
                          }
                      }
                      if (error) {
                          ANSDebug(@"Server response unzip error!");
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
                              [ANSQueue dispatchAsyncLogSerialQueueWithBlock:^{
                                  [ANSStrategyManager saveServerStrategyInfo:policyInfo];
                              }];
                          }
                      }
                      ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
                      checkResult.remarks = [NSString stringWithFormat:@"Send message failed. \nreason: %@",responseDict];
                      ANSBriefWarning(@"%@",[checkResult messageDisplay]);
                      AgentUnlock()
                  } @catch (NSException *exception) {
                      ANSDebug(@"PostRequest exception: %@", exception);
                      AgentUnlock()
                  }
              } failure:^(NSError *error) {
                  ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
                  checkResult.remarks = [NSString stringWithFormat:@"Send message failed. reason: %@",error.description];
                  ANSBriefWarning(@"%@",[checkResult messageDisplay]);
                  AgentUnlock()
                  return ;
              }];
            AgentLock()
            return uploadStatus;
        } @catch (NSException *exception) {
            ANSDebug(@"UploadBlock exception: %@", exception);
            AgentUnlock()
        }
    };
    
    [ANSQueue dispatchRequestSerialQueueWithBlock:^{
        [self uploadDataWithType:@"" limitCount:100 block:uploadBlock];
    }];
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
        
        ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
        
        __block NSString *blockServerUrl = nil;
        __block NSString *blockUploadData = nil ;
        __block NSDictionary *blockHttpHeader = nil;
        
        [ANSQueue dispatchSyncLogSerialQueueWithBlock:^{
            blockServerUrl = [[[ANSStrategyManager sharedManager] currentUrl] copy];
        }];
        if (blockServerUrl == nil || blockServerUrl.length == 0) {
            checkResult.remarks = @"Please set uploadURL";
            ANSBriefWarning(@"%@",[checkResult messageDisplay]);
            [_isSendingDataLock lock];
            isSendingData = NO;
            [_isSendingDataLock unlock];
            return;
        }
        
        __block NSArray *dataArray = nil;
        [ANSQueue dispatchSyncLogSerialQueueWithBlock:^{
            [self->_dbHelper getTopRecords:dataCount type:type result:^(BOOL success, NSArray *resultArray) {
                dataArray = resultArray;
                if (success && (dataArray.count > 0)) {
                    dataArray = [[ANSTimeCheckManager shared] checkDataArray:dataArray];
                    blockHttpHeader = [ANSEncryptUtis httpHeaderInfo];
                    NSString *jsonString = [NSString stringWithFormat:@"[%@]",[dataArray componentsJoinedByString:@","]];
                    blockUploadData = [[ANSEncryptUtis processUploadBody:jsonString param:blockHttpHeader] copy];
                    checkResult.remarks = [NSString stringWithFormat:@"Send message to server: %@ \ndata:\n%@\n", blockServerUrl, jsonString];
                    ANSBriefLog(@"%@",[checkResult messageDisplay]);
                }
            }];
        }];
        
        if (dataArray == nil || dataArray.count == 0) {
            [_isSendingDataLock lock];
            isSendingData = NO;
            [_isSendingDataLock unlock];
            return;
        }
        
        if (uploadBlock(blockServerUrl, blockHttpHeader, blockUploadData)) {
            checkResult.remarks = @"Send message success";
            
            __block BOOL cleanResult = NO;
            [ANSQueue dispatchSyncLogSerialQueueWithBlock:^{
                ANSBriefLog(@"%@",[checkResult messageDisplay]);
                [[ANSStrategyManager sharedManager] resetDelayStrategyFailedTry];
                cleanResult = [self->_dbHelper deleteUploadRecordsWithType:type];
            }];
            if (!cleanResult) {
                ANSDebug(@"Database delete error!");
                shouldUploadAgain = NO;
            }
        } else {
            [ANSQueue dispatchSyncLogSerialQueueWithBlock:^{
                [self->_dbHelper resetUploadRecordsWithType:type];
                [[ANSStrategyManager sharedManager] increaseDelayStrategyFailCount];
            }];
            shouldUploadAgain = NO;
        }
        
    } @catch (NSException *exception) {
        ANSDebug(@"Database query exception: %@", exception);
        shouldUploadAgain = NO;
    }
    [_isSendingDataLock lock];
    isSendingData = NO;
    [_isSendingDataLock unlock];
    
    if (shouldUploadAgain) {
        [self flushDataNotification:nil];
    }
}

#pragma mark - other

- (BOOL)isIgnoreTrackWithClassName:(NSString *)className {
    ANSPropertyLock();
    BOOL retValue = [_pageViewBlackList containsObject:className];
    ANSPropertyUnlock();
    return retValue;
}

- (BOOL)isTrackWithClassName:(NSString *)className {
    ANSPropertyLock();
    BOOL retValue = [_pageViewWhiteList containsObject:className];
    ANSPropertyUnlock();
    return retValue;
}

- (BOOL)hasPageViewWhiteList {
    ANSPropertyLock();
    BOOL retValue = (_pageViewWhiteList.count > 0);
    ANSPropertyUnlock();
    return retValue;
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

- (ANSDatabase *)getDBHelper {
    return _dbHelper;
}

- (AnalysysNetworkType)currentNetworkType {
    AnalysysNetworkType networkType = AnalysysNetworkALL;
    if (![[ANSTelephonyNetwork shareInstance] hasNetwork]) {
        networkType = AnalysysNetworkNONE;
    } else if ([[ANSTelephonyNetwork shareInstance] isWIFI]) {
        networkType = AnalysysNetworkWIFI;
    } else {
        networkType = AnalysysNetworkWWAN;
    }
    return networkType;
}

- (BOOL)isSDKInitBeforeInterface:(NSString *)interface {
    if (!_isSDKInit) {
        NSLog(@"[Analysys] [Log] The SDK is not initialized, please call %@ after initialization.", interface);
        return NO;
    } else {
        return YES;
    }
}

@end
