//
//  AnalysysAgent.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "AnalysysAgent.h"
#import "AnalysysSDK.h"

@implementation AnalysysAgentConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _channel = @"App Store";
        _autoProfile = YES;
    }
    return self;
}

+ (instancetype)shareInstance {
    static AnalysysAgentConfig *instance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[AnalysysAgentConfig alloc] init] ;
    });
    return instance;
}

@end


@implementation AnalysysAgent

+ (void)startWithConfig:(AnalysysAgentConfig *)config {
    [[AnalysysSDK sharedManager] startWithConfig:config];
}

+ (NSString *)SDKVersion {
    return [AnalysysSDK SDKVersion];
}

#pragma mark *** 服务器地址设置 ***

+ (void)setUploadURL:(NSString *)uploadURL {
    [[AnalysysSDK sharedManager] setUploadURL:uploadURL];
}

+ (void)setVisitorDebugURL:(NSString *)visitorDebugURL {
    [[AnalysysSDK sharedManager] setVisitorDebugURL:visitorDebugURL];
}

+ (void)setVisitorConfigURL:(NSString *)configURL {
    [[AnalysysSDK sharedManager] setVisitorConfigURL:configURL];
}

#pragma mark *** SDK发送策略 ***

+ (void)setDebugMode:(AnalysysDebugMode)debugMode {
    [[AnalysysSDK sharedManager] setDebugMode:debugMode];
}

+ (AnalysysDebugMode)debugMode {
    return [[AnalysysSDK sharedManager] debugMode];
}

+ (void)setIntervalTime:(NSInteger)flushInterval {
    [[AnalysysSDK sharedManager] setIntervalTime:flushInterval];
}

+ (void)setMaxEventSize:(NSInteger)size {
    [[AnalysysSDK sharedManager] setMaxEventSize:size];
}

+ (void)setMaxCacheSize:(NSInteger)size {
    [[AnalysysSDK sharedManager] setMaxCacheSize:size];
}

+ (NSInteger)maxCacheSize {
    return [[AnalysysSDK sharedManager] maxCacheSize];
}

+ (void)flush {
    [[AnalysysSDK sharedManager] flush];
}

#pragma mark *** 事件 ***

+ (void)track:(NSString *)event {
    [AnalysysAgent track:event properties:nil];
}

+ (void)track:(NSString *)event properties:(NSDictionary *)properties {
    [[AnalysysSDK sharedManager] track:event properties:properties];
}

#pragma mark *** 页面事件 ***

+ (void)pageView:(NSString *)pageName {
    [AnalysysAgent pageView:pageName properties:nil];
}

+ (void)pageView:(NSString *)pageName properties:(NSDictionary *)properties {
    [[AnalysysSDK sharedManager] pageView:pageName properties:properties];
}

+ (void)setAutomaticCollection:(BOOL)isAuto {
    [[AnalysysSDK sharedManager] setAutomaticCollection:isAuto];
}

+ (BOOL)isViewAutoTrack {
    return [[AnalysysSDK sharedManager] isViewAutoTrack];
}

+ (void)setIgnoredAutomaticCollectionControllers:(NSArray<NSString *> *)controllers {
    [[AnalysysSDK sharedManager] setIgnoredAutomaticCollectionControllers:controllers];
}

#pragma mark *** 通用属性 ***

+ (void)registerSuperProperties:(NSDictionary *)superProperties {
    [[AnalysysSDK sharedManager] registerSuperProperties:superProperties];
}

+ (void)registerSuperProperty:(NSString *)superPropertyName value:(id)superPropertyValue {
    [[AnalysysSDK sharedManager] registerSuperProperty:superPropertyName value:superPropertyValue];
}

+ (void)unRegisterSuperProperty:(NSString *)superPropertyName {
    [[AnalysysSDK sharedManager] unRegisterSuperProperty:superPropertyName];
}

+ (void)clearSuperProperties {
    [[AnalysysSDK sharedManager] clearSuperProperties];
}

+ (NSDictionary *)getSuperProperties {
    return [[AnalysysSDK sharedManager] getSuperProperties];
}

+ (id)getSuperProperty:(NSString *)superPropertyName {
    return [[AnalysysSDK sharedManager] getSuperProperty:superPropertyName];;
}

#pragma mark *** 用户信息相关 ***

+ (void)identify:(NSString *)anonymousId {
    [[AnalysysSDK sharedManager] identify:anonymousId];
}

+ (void)alias:(NSString *)aliasId originalId:(NSString *)originalId {
    [[AnalysysSDK sharedManager] alias:aliasId originalId:originalId];
}

+ (void)profileSet:(NSDictionary *)property {
    [[AnalysysSDK sharedManager] profileSet:property];
}

+ (void)profileSet:(NSString *)propertyName propertyValue:(id)propertyValue {
    [[AnalysysSDK sharedManager] profileSet:propertyName propertyValue:propertyValue];
}

+ (void)profileSetOnce:(NSDictionary *)property {
    [[AnalysysSDK sharedManager] profileSetOnce:property];
}

+ (void)profileSetOnce:(NSString *)propertyName propertyValue:(id)propertyValue {
    [[AnalysysSDK sharedManager] profileSetOnce:propertyName propertyValue:propertyValue];
}

+ (void)profileIncrement:(NSDictionary<NSString*, NSNumber*> *)property {
    [[AnalysysSDK sharedManager] profileIncrement:property];
}

+ (void)profileIncrement:(NSString *)propertyName propertyValue:(NSNumber *)propertyValue {
    [[AnalysysSDK sharedManager] profileIncrement:propertyName propertyValue:propertyValue];
}

+ (void)profileAppend:(NSDictionary *)property {
    [[AnalysysSDK sharedManager] profileAppend:property];
}

+ (void)profileAppend:(NSString *)propertyName value:(id)propertyValue {
    [[AnalysysSDK sharedManager] profileAppend:propertyName value:propertyValue];
}

+ (void)profileAppend:(NSString *)propertyName propertyValue:(NSSet<NSString *> *)propertyValue {
    [[AnalysysSDK sharedManager] profileAppend:propertyName propertyValue:propertyValue];
}

+ (void)profileUnset:(NSString *)propertyName {
    [[AnalysysSDK sharedManager] profileUnset:propertyName];
}

+ (void)profileDelete {
    [[AnalysysSDK sharedManager] profileDelete];
}

#pragma mark *** 清除本地设置 ***

+ (void)reset {
    [[AnalysysSDK sharedManager] reset];
}

#pragma mark *** Hybrid 页面 ***

+ (BOOL)setHybridModel:(id)webView request:(NSURLRequest *)request {
    return [[AnalysysSDK sharedManager] setHybridModel:webView request:request];
}

+ (void)resetHybridModel {
    [[AnalysysSDK sharedManager] resetHybridModel];
}


#pragma mark *** 活动推送效果 ***

/** 设置推送平台及第三方推送标识 */
+ (void)setPushProvider:(AnalysysPushProvider)provider pushID:(NSString *)pushID {
    [[AnalysysSDK sharedManager] setPushProvider:provider pushID:pushID];
}

/** 追踪活动推广 */
+ (void)trackCampaign:(id)userInfo isClick:(BOOL)isClick {
    [AnalysysAgent trackCampaign:userInfo isClick:isClick userCallback:nil];
}

/** 追踪活动推广，可回调用户自定义信息 */
+ (void)trackCampaign:(id)userInfo isClick:(BOOL)isClick userCallback:(void(^)(id campaignInfo))userCallback {
    [[AnalysysSDK sharedManager] trackCampaign:userInfo isClick:isClick userCallback:^(id  _Nonnull campaignInfo) {
        userCallback(campaignInfo);
    }];
}


@end
