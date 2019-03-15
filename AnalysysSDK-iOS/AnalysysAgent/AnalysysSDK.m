//
//  AnalysysSDK.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "AnalysysSDK.h"

#import <UIKit/UIKit.h>

#import "ANSConsleLog.h"
#import "ANSUtil.h"
#import "ANSConst.h"
#import "ANSDatabase.h"
#import "ANSFileManager.h"
#import "ANSGzip.h"

#import "ANSDeviceInfo.h"
#import "ANSTelephonyNetwork.h"
#import "ANSDataProcessing.h"
#import "ANSModuleProcessing.h"
#import "ANSStrategyManager.h"
#import "ANSSession.h"
#import "ANSUploadManager.h"
#import "ANSPageAutoTrack.h"
#import "ANSHybrid.h"
#import "ANSOpenURLAutoTrack.h"

#define AgentLock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER);
#define AgentUnlock() dispatch_semaphore_signal(self->_lock);

static AnalysysSDK *sharedInstance = nil;

/** 数据存储标识 */
static NSString *ANSIsAutoTrack = @"eg_autotrack";

//  默认上传端口
static NSString *const AnsHttpsDefaultPort = @"4089";


/**
 reset类型
 - ANSStartReset: 启动重置(切换appkey、serverUrl、debug模式)
 - ANSProfileReset: profile接口调用重置
 */
typedef enum : NSUInteger {
    ANSStartReset,
    ANSProfileReset
} ANSResetType;

/**
 事件分类
 - ANSEventTrack: 自定义事件
 - ANSEventPage: 页面事件
 - ANSEventProfile: profile系列事件
 - ANSEventAlias: 账号登录事件
 - ANSEventAppActive: App进入前台
 - ANSEventAppResignActive: App退入后台
 */
typedef enum : NSUInteger {
    ANSEventTrack,
    ANSEventPage,
    ANSEventProfile,
    ANSEventAlias,
    ANSEventAppActive,
    ANSEventAppResignActive,
    ANSEventHeatMap
} ANSEventType;


@interface AnalysysSDK () {
    BOOL _isAppLaunched; // 是否launch启动，防止pageview事件先于start事件
    BOOL _isFirstTime;  // 是否首次安装启动
    dispatch_semaphore_t _lock;
    NSInteger _maxCacheSize;  // 本地允许最大缓存
    long long _appEnterForgroundTime;  // App活跃
    long long _appEnterBackgroundTime;  // App进入后台
}

@property (nonatomic, strong) ANSDatabase *dbHelper;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) NSDateFormatter *dateFmt;

@end

@implementation AnalysysSDK {
    dispatch_queue_t _serialQueue; //  数据队列
    dispatch_queue_t _networkQueue;    //  网络上传队列
    NSOperationQueue *_operationQueue; //  队列管理
    NSMutableArray *_ignoredViewControllers;    //  忽略自动采集的页面
    NSDateFormatter *_timeFormatter; //  时间校准
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
        _isAppLaunched = YES;
        _lock = dispatch_semaphore_create(0);
        _isBackgroundActive = NO;
        _maxCacheSize = 10000;
        _ignoredViewControllers = [NSMutableArray array];
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _appEnterForgroundTime = [ANSUtil currentTimeMillisecond];
        
        _dateFmt = [[NSDateFormatter alloc] init];
        _dateFmt.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        _dateFmt.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
        
        _timeFormatter = [[NSDateFormatter alloc] init];
        [_timeFormatter setTimeStyle:NSDateFormatterFullStyle];
        [_timeFormatter setDateFormat:@"EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"];
        [_timeFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
        [_timeFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"]];
        
        NSString *serialLabel = [NSString stringWithFormat:@"com.analysys.serialQueue"];
        _serialQueue = dispatch_queue_create([serialLabel UTF8String], DISPATCH_QUEUE_SERIAL);
        
        NSString *netLabel = [NSString stringWithFormat:@"com.analysys.networkQueue"];
        _networkQueue = dispatch_queue_create([netLabel UTF8String], DISPATCH_QUEUE_SERIAL);
        
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
        
        [[ANSTelephonyNetwork shareInstance] startReachability];
        
        [ANSOpenURLAutoTrack autoTrack];
        
        [ANSPageAutoTrack autoTrack];
        
        [self registNotifications];
        
        _dbHelper = [[ANSDatabase alloc] initWithDatabaseName:@"ANALYSYS.db"];
        
    }
    return self;
}

- (void)startWithConfig:(AnalysysAgentConfig *)config {
    if (config.appKey.length == 0) {
        [ANSConsleLog logWarning:@"startWithConfig" value:nil detail:@"'appKey' can not be empty"];
        return;
    }
    NSString *upServerUrl;
    if (config.baseUrl.length > 0) {
        upServerUrl = [NSString stringWithFormat:@"https://%@:%@/up", config.baseUrl, AnsHttpsDefaultPort];
        
        //  可视化模块
        [[ANSModuleProcessing sharedManager] setVisualBaseUrl:config.baseUrl];
    }
    @try {
        //  检查appkey和server是否变更
        if (![self isAppKeyChanged:config.appKey] &
            ![self isServerURLChanged:upServerUrl]) {
            [self checkAppFirstStart];
        }
        
        NSLog(@"\n\n---------------------- [Analysys] [Log] ---------------------- \
              \n------ Init iOS Analysys OC SDK Success. Version: %@ ------ \
              \n--------------------------------------------------------------",ANSSDKVersion);
        
        [self trackAppStartEvent];
    } @catch (NSException *exception) {
        AnsDebug(@"SDK init exception: %@", exception);
    }
}

/** 当前SDK版本 */
+ (NSString *)SDKVersion {
    return ANSSDKVersion;
}

#pragma mark *** --------- public interface --------- ***

#pragma mark *** 服务器地址设置 ***

/** 设置上传数据地址 */
- (void)setUploadURL:(NSString *)uploadURL {
    if (![uploadURL hasPrefix:@"http://"] && ![uploadURL hasPrefix:@"https://"]) {
        [ANSConsleLog logWarning:@"setUploadURL" value:uploadURL detail:@"'uploadURL' must start with 'http://' or 'https://'"];
        return;
    }
    NSString *serverUrl = [NSString stringWithFormat:@"%@/up",uploadURL];
    [self isServerURLChanged:serverUrl];
    
    [ANSConsleLog logSuccess:@"setUploadURL" value:uploadURL];
}

/** 设置可视化websocket服务器地址 */
- (void)setVisitorDebugURL:(NSString *)visitorDebugURL {
    [[ANSModuleProcessing sharedManager] setVisitorDebugURL:visitorDebugURL];
}

/** 设置线上请求埋点配置的服务器地址 */
- (void)setVisitorConfigURL:(NSString *)configURL {
    [[ANSModuleProcessing sharedManager] setVisualConfigUrl:configURL];
}

#pragma mark *** SDK发送策略 ***

/** debug模式 */
- (void)setDebugMode:(AnalysysDebugMode)debugMode {
    switch (debugMode) {
        case AnalysysDebugOff:
        case AnalysysDebugOnly:
        case AnalysysDebugButTrack: {
            [self isDebugModeChanged:debugMode];
            [ANSConsleLog logSuccess:@"setDebugMode" value:nil];
        }
            break;
        default:
            [ANSConsleLog logWarning:@"setDebugMode" value:nil detail:@"must be enumeration(AnalysysDebugMode)"];
            break;
    }
}

/** 当前调试模式 */
- (AnalysysDebugMode)debugMode {
    return [ANSStrategyManager sharedManager].currentUseDebugMode;
}

/** 设置上传间隔时间 */
- (void)setIntervalTime:(NSInteger)flushInterval {
    NSInteger _flushInterval = MAX(1, flushInterval);
    [ANSStrategyManager sharedManager].userStrategy.flushInterval = _flushInterval;
    
    [ANSConsleLog logSuccess:@"setIntervalTime" value:[NSNumber numberWithInteger:_flushInterval]];
}

/** 数据累积"size"条数后触发上传 */
- (void)setMaxEventSize:(NSInteger)flushSize {
    NSInteger _flushSize = MAX(1, flushSize);
    [ANSStrategyManager sharedManager].userStrategy.flushBulkSize = _flushSize;
    
    [ANSConsleLog logSuccess:@"setMaxEventSize" value:[NSNumber numberWithInteger:_flushSize]];
}

/** 本地缓存上限值 */
- (void)setMaxCacheSize:(NSInteger)cacheSize {
    _maxCacheSize = MAX(100, cacheSize);
    
    [ANSConsleLog logSuccess:@"setMaxCacheSize" value:[NSNumber numberWithInteger:_maxCacheSize]];
}

/** 获取当前设置的本地最大存储 */
- (NSInteger)maxCacheSize {
    return _maxCacheSize;
}

/** 主动向服务器上传数据 */
- (void)flush {
    [self flushDataIfIgnorePolicy:YES];
}

#pragma mark *** 事件 ***

/** 添加事件 */
- (void)track:(NSString *)event {
    [self track:event properties:nil];
}

/** 添加事件及附加属性 */
- (void)track:(NSString *)event properties:(NSDictionary *)properties {
    NSDictionary *trackInfo = [[ANSDataProcessing sharedManager] processTrack:event properties:properties];
    if (trackInfo) {
        [self saveUploadInfo:trackInfo eventType:ANSEventTrack handler:^{
            [ANSConsleLog logSuccess:@"track" value:nil];
        }];
    } else {
        [ANSConsleLog logWarning:@"track" value:event detail:nil];
    }
}

#pragma mark *** 页面事件 ***

/** 页面跟踪 */
- (void)pageView:(NSString *)pageName {
    [self pageView:pageName properties:nil];
}

/** 页面跟踪及附加属性 */
- (void)pageView:(NSString *)pageName properties:(NSDictionary *)properties {
    NSString *url = properties[@"$url"];
    NSString *title = properties[@"$title"];
    
    NSMutableDictionary *sdkProperties = [NSMutableDictionary dictionary];
    sdkProperties[@"$url"] = url;
    sdkProperties[@"$title"] = title;
    sdkProperties[@"$pagename"] = pageName;
    
    NSMutableDictionary *pageProperties = [NSMutableDictionary dictionaryWithDictionary:properties];
    pageProperties[@"$url"] = nil;
    pageProperties[@"$title"] = nil;
    
    // url scheme
    NSDictionary *utm = [ANSOpenURLAutoTrack utmParameters];
    [pageProperties addEntriesFromDictionary:utm];
    [ANSOpenURLAutoTrack saveUtmParameters:nil];
    
    NSDictionary *pageInfo = [[ANSDataProcessing sharedManager] processPageProperties:pageProperties SDKProperties:sdkProperties];
    if (pageInfo) {
        [self saveUploadInfo:pageInfo eventType:ANSEventTrack handler:^{
            [ANSConsleLog logSuccess:@"pageView" value:nil];
        }];
    } else {
        [ANSConsleLog logWarning:@"pageView" value:pageName detail:nil];
    }
}

/** 设置是否允许页面自动采集 */
- (void)setAutomaticCollection:(BOOL)isAuto {
    [ANSFileManager sharedManager].normalProperties[ANSIsAutoTrack] = [NSNumber numberWithBool:isAuto];
    [ANSFileManager saveNormalProperties];
}

/** 当前SDK是否允许页面自动跟踪 */
- (BOOL)isViewAutoTrack {
    return [[ANSFileManager sharedManager].normalProperties[ANSIsAutoTrack] boolValue];
}

/** 忽略部分页面自动采集 */
- (void)setIgnoredAutomaticCollectionControllers:(NSArray<NSString *> *)controllers {
    if (controllers.count == 0) {
        return;
    }
    [_ignoredViewControllers addObjectsFromArray:controllers];
}

#pragma mark *** 通用属性 ***

/** 注册通用属性 */
- (void)registerSuperProperties:(NSDictionary *)superProperties {
    if (superProperties.allKeys.count == 0) {
        return;
    }
    if (![[ANSDataProcessing sharedManager] isValidOfProperties:superProperties]) {
        [ANSConsleLog logWarning:@"registerSuperProperties" value:nil detail:nil];
        return;
    }
    BOOL result = [self archiveGlobalProperties:superProperties];
    if (result) {
        [ANSConsleLog logSuccess:@"registerSuperProperties" value:nil];
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
    [ANSFileManager sharedManager].globalProperties[superPropertyName] = nil;
    BOOL result = [self archiveGlobalProperties:nil];
    if (result) {
        [ANSConsleLog logSuccess:@"unRegisterSuperProperty" value:nil];
    }
}

/** 清除所有通用属性 */
- (void)clearSuperProperties {
    [[ANSFileManager sharedManager].globalProperties removeAllObjects];
    BOOL result = [self archiveGlobalProperties:nil];
    if (result) {
        [ANSConsleLog logSuccess:@"clearSuperProperties" value:nil];
    }
}

/** 获取通用属性 */
- (NSDictionary *)getSuperProperties {
    return [[ANSFileManager sharedManager].globalProperties copy];
}

/** 获取某个通用属性 */
- (id)getSuperProperty:(NSString *)superPropertyName {
    return [ANSFileManager sharedManager].globalProperties[superPropertyName];;
}

#pragma mark *** 用户信息相关 ***

/** 匿名用户ID设置 */
- (void)identify:(NSString *)anonymousId {
    if (![[ANSDataProcessing sharedManager] isValidOfIdentify:anonymousId]) {
        [ANSConsleLog logWarning:@"identify" value:nil detail:nil];
        return;
    }
    [ANSFileManager sharedManager].normalProperties[ANSAnonymousId] = anonymousId;
    BOOL result = [ANSFileManager saveNormalProperties];
    if (result) {
        [ANSConsleLog logSuccess:@"identify" value:anonymousId];
    }
}

/** 用户关联 */
- (void)alias:(NSString *)aliasId originalId:(NSString *)originalId {
    if (![[ANSDataProcessing sharedManager] isValidOfAliasId:aliasId]) {
        [ANSConsleLog logWarning:@"alias" value:nil detail:nil];
        return;
    }
    if (![[ANSDataProcessing sharedManager] isValidOfAliasOriginalId:originalId]) {
        [ANSConsleLog logWarning:@"alias" value:nil detail:nil];
        return;
    }
    ANSFileManager *fileManager = [ANSFileManager sharedManager];
    fileManager.normalProperties[ANSAlias] = aliasId;
    fileManager.normalProperties[ANSOriginalId] = originalId;
    [ANSFileManager saveNormalProperties];
    
    // original_id
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    NSString *anonymousId = fileManager.normalProperties[ANSAnonymousId];
    if (originalId.length > 0) {
        properties[ANSOriginalId] = originalId;
    } else if (anonymousId.length > 0) {
        properties[ANSOriginalId] = anonymousId;
    } else {
        properties[ANSOriginalId] = fileManager.normalProperties[ANSUUID];
    }
    
    NSDictionary *aliasInfo = [[ANSDataProcessing sharedManager] processAliasSDKProperties:properties];
    if (aliasInfo) {
        [self saveUploadInfo:aliasInfo eventType:ANSEventAlias handler:^{
            [ANSConsleLog logSuccess:@"alias" value:nil];
        }];
        [self upProfileSetOnce];
    } else {
        [ANSConsleLog logWarning:@"alias" value:nil detail:nil];
    }
}

/** 设置用户属性 */
- (void)profileSet:(NSDictionary *)property {
    if (property == nil || property.allKeys.count == 0) {
        return;
    }
    if (![[ANSDataProcessing sharedManager] isValidOfProperties:property]) {
        [ANSConsleLog logWarning:@"profileSet" value:nil detail:nil];
        return;
    }
    NSDictionary *upInfo = [[ANSDataProcessing sharedManager] processProfileSetProperties:property];
    [self saveUploadInfo:upInfo eventType:ANSEventProfile handler:^{
        [ANSConsleLog logSuccess:@"profileSet" value:nil];
    }];
}

- (void)profileSet:(NSString *)propertyName propertyValue:(id)propertyValue {
    if (propertyName && propertyValue) {
        [self profileSet:@{propertyName: propertyValue}];
    }
}

/** 设置用户固有属性 */
- (void)profileSetOnce:(NSDictionary *)property {
    if (property == nil || property.allKeys.count == 0) {
        return;
    }
    if ([[ANSDataProcessing sharedManager] isValidOfProperties:property]) {
        NSDictionary *upInfo = [[ANSDataProcessing sharedManager] processProfileSetOnceProperties:property SDKProperties:nil];
        [self saveUploadInfo:upInfo eventType:ANSEventProfile handler:^{
            [ANSConsleLog logSuccess:@"profileSetOnce" value:nil];
        }];
    } else {
        [ANSConsleLog logWarning:@"profileSetOnce" value:nil detail:nil];
    }
}

- (void)profileSetOnce:(NSString *)propertyName propertyValue:(id)propertyValue {
    if (propertyName && propertyValue) {
        [self profileSetOnce:@{propertyName: propertyValue}];
    }
}

/** 设置用户属性相对变化值 */
- (void)profileIncrement:(NSDictionary<NSString*, NSNumber*> *)property {
    if (property == nil || property.allKeys.count == 0) {
        return;
    }
    if ([[ANSDataProcessing sharedManager] isValidOfIncrementProperties:property]) {
        NSDictionary *upInfo = [[ANSDataProcessing sharedManager] processProfileIncrementProperties:property];
        [self saveUploadInfo:upInfo eventType:ANSEventProfile handler:^{
            [ANSConsleLog logSuccess:@"profileIncrement" value:nil];
        }];
    } else {
        [ANSConsleLog logWarning:@"profileIncrement" value:nil detail:nil];
    }
}

/** profileIncrement */
- (void)profileIncrement:(NSString *)propertyName propertyValue:(NSNumber *)propertyValue {
    if (propertyName && propertyValue) {
        [self profileIncrement:@{propertyName: propertyValue}];
    }
}

/** 增加列表类型的属性 */
- (void)profileAppend:(NSDictionary *)property {
    if (property == nil || property.allKeys.count == 0) {
        return;
    }
    NSMutableDictionary *appendProperty = [NSMutableDictionary dictionaryWithDictionary:property];
    for (id key in property.allKeys) {
        id value = property[key];
        if ([value isKindOfClass:NSString.class]) {
            appendProperty[key] = [NSArray arrayWithObject:value];
        }
    }
    if ([[ANSDataProcessing sharedManager] isValidOfAppendProperties:appendProperty]) {
        NSDictionary *upInfo = [[ANSDataProcessing sharedManager] processProfileAppendProperties:appendProperty];
        [self saveUploadInfo:upInfo eventType:ANSEventProfile handler:^{
            [ANSConsleLog logSuccess:@"profileAppend" value:nil];
        }];
    } else {
        [ANSConsleLog logWarning:@"profileAppend" value:nil detail:nil];
    }
}

/** 增加key-value用户属性 */
- (void)profileAppend:(NSString *)propertyName value:(id)propertyValue {
    if (propertyName && propertyValue) {
        [self profileAppend:@{propertyName: propertyValue}];
    }
}

/** 增加key-value set集合用户属性 */
- (void)profileAppend:(NSString *)propertyName propertyValue:(NSSet<NSString *> *)propertyValue {
    if (propertyName && propertyValue) {
        [self profileAppend:@{propertyName: propertyValue}];
    }
}

/** 删除某个用户属性 */
- (void)profileUnset:(NSString *)propertyName {
    if (![[ANSDataProcessing sharedManager] isValidOfpropertyKey:propertyName]) {
        [ANSConsleLog logWarning:@"profileUnset" value:nil detail:nil];
        return;
    }
    NSDictionary *upInfo = [[ANSDataProcessing sharedManager] processProfileUnsetWithSDKProperties:@{propertyName: @""}];
    [self saveUploadInfo:upInfo eventType:ANSEventProfile handler:^{
        [ANSConsleLog logSuccess:@"profileUnset" value:nil];
    }];
}

/** 删除当前用户的所有属性 */
- (void)profileDelete {
    NSDictionary *upInfo = [[ANSDataProcessing sharedManager] processProfileDelete];
    [self saveUploadInfo:upInfo eventType:ANSEventProfile handler:^{
        [ANSConsleLog logSuccess:@"profileDelete" value:nil];
    }];
}

#pragma mark *** 清除本地设置 ***

/** 清除本地设置 */
- (void)reset {
    [self profileResetWithType:ANSProfileReset];
}

#pragma mark *** Hybrid 页面 ***

/** UIWebView和WKWebView统计 */
- (BOOL)setHybridModel:(id)webView request:(NSURLRequest *)request {
    if (webView == nil) {
        return NO;
    }
    @try {
        return [ANSHybrid excuteRequest:request webView:webView];
    } @catch (NSException *exception) {
        AnsError(@"Hyrbrid error:%@!", exception.description);
    }
}

/** 结束 Hybrid 模式 */
- (void)resetHybridModel {
    [ANSHybrid resetHybridModel];
}

#pragma mark *** 活动推送效果 ***

/** 设置推送平台及第三方推送标识 */
- (void)setPushProvider:(AnalysysPushProvider)provider pushID:(NSString *)pushID {
    if (![ANSModuleProcessing existsPushModule]) {
        return;
    }
    NSMutableDictionary *pushDic = [NSMutableDictionary dictionary];
    switch (provider) {
        case AnalysysPushJiGuang:
            pushDic[@"$JPUSH"] = pushID;
            break;
        case AnalysysPushGeTui:
            pushDic[@"$GETUI"] = pushID;
            break;
        case AnalysysPushBaiDu:
            pushDic[@"$BAIDU"] = pushID;
            break;
        case AnalysysPushXiaoMi:
            pushDic[@"$XIAOMI"] = pushID;
            break;
        default:
            break;
    }
    NSDictionary *upInfo = [[ANSDataProcessing sharedManager] processProfileSetProperties:pushDic];
    [self saveUploadInfo:upInfo eventType:ANSEventProfile handler:^{
        [ANSConsleLog logSuccess:@"profileSet" value:@"pushProvider"];
    }];
}

/** 追踪活动推广 */
- (void)trackCampaign:(id)userInfo isClick:(BOOL)isClick {
    [self trackCampaign:userInfo isClick:isClick userCallback:nil];
}

/** 追踪活动推广，可回调用户自定义信息 */
- (void)trackCampaign:(id)userInfo isClick:(BOOL)isClick userCallback:(void(^ _Nullable )(id campaignInfo))userCallback {
    NSDictionary *analysysPushInfo = [[ANSModuleProcessing sharedManager] parsePushInfo:userInfo];
    if (analysysPushInfo) {
        if (userCallback) {
            userCallback(analysysPushInfo);
        }
        NSDictionary *contextProperty = [[ANSModuleProcessing sharedManager] pushContext:analysysPushInfo];
        if (!contextProperty) {
            return;
        }
        if (isClick) {
            NSDictionary *pushClickInfo = [[ANSDataProcessing sharedManager] processSDKEvent:@"$push_click" properties:contextProperty];
            if (pushClickInfo) {
                [self saveUploadInfo:pushClickInfo eventType:ANSEventTrack handler:^{
                    [ANSConsleLog logSuccess:@"track" value:@"push_click"];
                }];
            }
            
            [[ANSModuleProcessing sharedManager] pushClickParameter:analysysPushInfo];
            
            NSDictionary *pushProcessInfo = [[ANSDataProcessing sharedManager] processSDKEvent:@"$push_process_success" properties:contextProperty];
            if (pushProcessInfo) {
                [self saveUploadInfo:pushProcessInfo eventType:ANSEventTrack handler:^{
                    [ANSConsleLog logSuccess:@"track" value:@"push_process_success"];
                }];
            }
        } else {
            NSDictionary *pushReceiverInfo = [[ANSDataProcessing sharedManager] processSDKEvent:@"$push_receiver_success" properties:contextProperty];
            if (pushReceiverInfo) {
                [self saveUploadInfo:pushReceiverInfo eventType:ANSEventTrack handler:^{
                    [ANSConsleLog logSuccess:@"track" value:@"$push_receiver_success"];
                }];
            }
        }
    }
}

#pragma mark *** 热图 ***

- (void)trackHeatMap {
    NSDictionary *heatMap = [[ANSDataProcessing sharedManager] processHeatMap];
    [self saveUploadInfo:heatMap eventType:ANSEventHeatMap handler:^{}];
}

#pragma mark *** --------- private method --------- ***

#pragma mark *** 队列 ***

/** 串行队列 */
- (void)dispatchOnSerialQueue:(void(^)(void))dispatchBlock {
    dispatch_async(_serialQueue, ^{
        dispatchBlock();
    });
}

#pragma mark *** 重要信息改变 ***

/** appKey是否更改 */
- (BOOL)isAppKeyChanged:(NSString *)appKey {
    NSString *lastAppKey = [ANSFileManager usedAppKey];
    [ANSFileManager saveAppKey:appKey];
    
    if (lastAppKey.length > 0 && ![lastAppKey isEqualToString:appKey]) {
        [self profileResetWithType:ANSStartReset];
        return YES;
    }
    return NO;
}

/** 上传地址是否更改 */
- (BOOL)isServerURLChanged:(NSString *)serverUrl {
    NSString *lastServer = [ANSStrategyManager sharedManager].currentUseServerUrl;
    [ANSStrategyManager sharedManager].userStrategy.serverUrl = serverUrl;
    
    if (lastServer.length > 0 && serverUrl.length > 0 && ![lastServer isEqualToString:serverUrl]) {
        [self profileResetWithType:ANSStartReset];
        return YES;
    }
    return NO;
}

/** debug模式是否更改 */
- (BOOL)isDebugModeChanged:(AnalysysDebugMode)debugMode {
    AnalysysDebugMode lastDebug = [ANSStrategyManager sharedManager].currentUseDebugMode;
    [ANSStrategyManager sharedManager].userStrategy.debugMode = debugMode;
    
    if ((lastDebug == AnalysysDebugOnly && debugMode == AnalysysDebugButTrack) ||
        (lastDebug == AnalysysDebugOnly && debugMode == AnalysysDebugOff)) {
        [self profileResetWithType:ANSStartReset];
        return YES;
    }
    return NO;
}

#pragma mark *** 通知及处理 ***

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
    [notificationCenter addObserver:self selector:@selector(cancelOperationsNotification:) name:ANSCancelOperationQueueNotification object:nil];
}

/** App 变为活跃状态 */
- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification {
    _appEnterForgroundTime = [ANSUtil currentTimeMillisecond];
    
    if (!_isAppLaunched) {
        [self trackAppStartEvent];
    }
    _isAppLaunched = NO;
}

/** app变为非活跃状态 */
- (void)applicationWillResignActiveNotification:(NSNotification *)notification {
    _isBackgroundActive = YES;
    _appEnterBackgroundTime = [ANSUtil currentTimeMillisecond];
    [[ANSSession shareInstance] updatePageDisappearDate];
    
    NSDictionary *endEvent = [[ANSDataProcessing sharedManager] processAppEnd];
    [self saveUploadInfo:endEvent eventType:ANSEventAppResignActive handler:^{}];
}

/** 数据上传 */
- (void)flushDataNotification:(NSNotification *)notification {
    [self flushDataIfIgnorePolicy:NO];
}

/** 取消所有队列中的上传 */
- (void)cancelOperationsNotification:(NSNotification *)notification {
    [_operationQueue cancelAllOperations];
}

#pragma mark *** 事件处理 ***

/** App启动事件 */
- (void)trackAppStartEvent {
    //  先生成session 后记录时间
    [[ANSSession shareInstance] generateSessionId];
    [[ANSSession shareInstance] updatePageAppearDate];
    [[ANSSession shareInstance] updatePageDisappearDate];
    
    NSDictionary *startEvent = [[ANSDataProcessing sharedManager] processAppStart];
    [self saveUploadInfo:startEvent eventType:ANSEventAppActive handler:^{}];
    
    if (_isFirstTime) {
        [self upProfileSetOnce];
    }
    _isFirstTime = NO;
    
    [ANSPageAutoTrack autoTrackLastVisitPage];
}

/** 上传一次 set_once 数据 */
- (void)upProfileSetOnce {
    if (AnalysysConfig.autoProfile) {
        NSString *dateStr = [self.dateFmt stringFromDate:[NSDate date]];
        NSString *language = [ANSDeviceInfo sharedManager].language;
        NSDictionary *properties = @{@"$first_visit_time": dateStr,
                                     @"$first_visit_language": language};
        NSDictionary *setOnce = [[ANSDataProcessing sharedManager] processProfileSetOnceProperties:nil SDKProperties:properties];
        [self saveUploadInfo:setOnce eventType:ANSEventProfile handler:^{}];
    }
}

/** 重置本地缓存 */
- (void)profileResetWithType:(ANSResetType)resetType {
    ANSFileManager *fileManager = [ANSFileManager sharedManager];
    if (resetType == ANSProfileReset) {
        fileManager.normalProperties[ANSUUID] = [[NSUUID UUID] UUIDString];
    }
    fileManager.normalProperties[ANSAnonymousId] = nil;
    fileManager.normalProperties[ANSAlias] = nil;
    fileManager.normalProperties[ANSOriginalId] = nil;
    fileManager.globalProperties = [NSMutableDictionary dictionary];
    
    [_userDefaults setObject:nil forKey:ANSAppLaunchDate];
    [_userDefaults synchronize];
    
    [self.dbHelper deleteTopRecords:0 type:0];
    
    //  保证startpup、更改debug、更改serverUrl后，能按正常顺序执行
    [self dispatchOnSerialQueue:^{
        [ANSFileManager saveNormalProperties];
        [ANSFileManager saveGlobalProperties];
        
        if (resetType == ANSProfileReset && AnalysysConfig.autoProfile) {
            [self sendResetInfo];
        }
    }];
}

/** 发送reset事件 */
- (void)sendResetInfo {
    NSString *dateStr = [self.dateFmt stringFromDate:[NSDate date]];
    NSDictionary *upInfo = [[ANSDataProcessing sharedManager] processProfileSetOnceProperties:nil SDKProperties:@{@"$reset_time": dateStr}];
    [self saveUploadInfo:upInfo eventType:ANSEventProfile handler:^{
        [ANSConsleLog logSuccess:@"profile_reset" value:nil];
    }];
}

#pragma mark *** 数据存储及上传 ***

/** 首次启动 */
- (void)checkAppFirstStart {
    if (![_userDefaults objectForKey:ANSAppLaunchDate]) {
        _isFirstTime = YES;
        [ANSStrategyManager sharedManager].userStrategy.debugMode = 0;
        ANSFileManager *fileManager = [ANSFileManager sharedManager];
        if (fileManager.normalProperties[ANSIsAutoTrack] == nil) {
            fileManager.normalProperties[ANSIsAutoTrack] = [NSNumber numberWithBool:YES];
        }
        fileManager.normalProperties[ANSUUID] = [[NSUUID UUID] UUIDString];
        [ANSFileManager saveNormalProperties];
    }
}

/** 存储通用属性 */
- (BOOL)archiveGlobalProperties:(NSDictionary *)properties {
    [[ANSFileManager sharedManager].globalProperties addEntriesFromDictionary:properties];
    return [ANSFileManager saveGlobalProperties];
}

/** 数据存储 */
- (void)saveUploadInfo:(NSDictionary *)dataInfo eventType:(ANSEventType)eventType handler:(void(^)(void))handler {
    if (!dataInfo) {
        return;
    }
    [self dispatchOnSerialQueue:^{
        BOOL success = [self.dbHelper insertRecordObject:dataInfo type:eventType];
        if (success) {
            handler();
            
            [self uploadDataType:eventType];
        }
    }];
}

/** 根据条件上传数据 */
- (void)uploadDataType:(ANSEventType)eventType {
    if (eventType == ANSEventAlias) {
        //  alias不受策略控制
        [self flushDataIfIgnorePolicy:YES];
    } else {
        if ([[ANSStrategyManager sharedManager] canUploadWithDataCount:self.dbHelper.recordRows]) {
            [self flushDataIfIgnorePolicy:NO];
        }
    }
}

/** 数据上传 */
- (void)flushDataIfIgnorePolicy:(BOOL)ignoreDelay {
    if (![[ANSTelephonyNetwork shareInstance] hasNetwork]) {
        [ANSConsleLog logWarning:nil value:nil detail:@"Please check the network status"];
        return;
    }
    
    dispatch_async(_networkQueue, ^{
        BOOL (^uploadBlock)(NSString*, NSDictionary*, NSString*) = ^(NSString *serverUrl, NSDictionary *httpHeader, NSString *uploadInfo) {
            @try {
                __block BOOL uploadStatus = NO;
                [ANSUploadManager postRequestWithServerURLStr:serverUrl
                                                       header:httpHeader
                                                         body:uploadInfo
                                                      success:^(NSURLResponse *response, NSData *responseData) {
                  NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
                  [self checkTimeWithResponse:res];
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
                        } else if ([responseDict[@"code"] integerValue] == 500) {
                            id policyInfo = responseDict[@"policy"];
                            if ([policyInfo isKindOfClass:[NSDictionary class]]) {
                                [ANSStrategyManager saveServerStrategyInfo:policyInfo];
                            }
                        } else {
                            [ANSConsleLog logWarning:nil value:nil detail:[NSString stringWithFormat:@"Send message failed. reason: %@",responseDict]];
                        }
                        AgentUnlock()
                    } @catch (NSException *exception) {
                        AnsDebug(@"PostRequest exception: %@", exception);
                        AgentUnlock()
                    }
                } failure:^(NSError *error) {
                    [ANSConsleLog logWarning:nil value:nil detail:[NSString stringWithFormat:@"Send message failed. reason: %@",error.description]];
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
        
        NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            [self uploadDataWithType:@"" limitCount:100 block:uploadBlock];
        }];
        [self->_operationQueue addOperation:blockOperation];
    });
}

/** 获取本地上传数据并回调 */
- (void)uploadDataWithType:(NSString *)type limitCount:(NSInteger)dataCount block:(BOOL (^)(NSString*, NSDictionary*, NSString*))uploadBlock {
    while (true) {
        @try {
            //  循环获取上传数据
            NSArray *dataArray = [_dbHelper getTopRecords:dataCount type:type];
            if (dataArray == nil || dataArray.count == 0) {
                break;
            }
            NSString *serverUrl = [ANSStrategyManager sharedManager].currentUseServerUrl;
            if (serverUrl == nil || serverUrl.length == 0) {
                [ANSConsleLog logWarning:nil value:nil detail:@"Please set uploadURL"];
                break;
            }
            
            NSDictionary *httpHeader = [ANSUtil httpHeaderInfo];
            NSString *dataJsonString = [NSString stringWithFormat:@"[%@]",[dataArray componentsJoinedByString:@","]];
            NSString *uploadInfo = [ANSUtil processUploadBody:dataJsonString param:httpHeader];
            
            [ANSConsleLog logSuccess:nil value:[NSString stringWithFormat:@"Send message to server: %@ \ndata:\n%@\n", serverUrl, dataJsonString]];
            
            if (uploadBlock(serverUrl, httpHeader, uploadInfo)) {
                [ANSConsleLog logSuccess:nil value:@"Send message success"];
                
                if ([ANSStrategyManager sharedManager].delayStrategy.currentFailedCount) {
                    [[ANSStrategyManager sharedManager].delayStrategy resetFailedTry];
                }

                BOOL cleanResult = [_dbHelper deleteTopRecords:dataArray.count type:type];
                if (!cleanResult) {
                    AnsDebug(@"Database delete error!");
                    break;
                }
            } else {
                [[ANSStrategyManager sharedManager].delayStrategy increaseFailCount];
                break;
            }
        } @catch (NSException *exception) {
            AnsDebug(@"Database query exception: %@", exception);
        }
    }
}

#pragma mark *** other ***

/** 时间校准 */
- (void)checkTimeWithResponse:(NSHTTPURLResponse *)response {
    NSString *string = [NSString stringWithFormat:@"%@", response.allHeaderFields[@"Date"]];
    NSDate *date = [_timeFormatter dateFromString:string];
    NSTimeInterval serverTimeInterval = [date timeIntervalSince1970]*1000;
    NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970]*1000;
    
    [ANSFileManager sharedManager].normalProperties[ANSServerTimeInterval] = [NSNumber numberWithDouble:(serverTimeInterval - nowTimeInterval)];
    [ANSFileManager saveNormalProperties];
}

- (BOOL)isIgnoreTrackWithClassName:(NSString *)className {
    return [_ignoredViewControllers containsObject:className];
}

- (NSNumber *)appDuration {
    long long duration = _appEnterBackgroundTime - _appEnterForgroundTime;
    return [NSNumber numberWithLongLong:duration];
}



@end
