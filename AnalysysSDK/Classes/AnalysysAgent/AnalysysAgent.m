//
//  AnalysysAgent.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "AnalysysAgent.h"
#import "AnalysysSDK.h"
#import "ANSAppStartSource.h"
#import <objc/runtime.h>
#import "ANSAllBuryPoint.h"
#import "ANSUncaughtExceptionHandler.h"
@implementation UIViewController (ANSViewController)

- (void)setAutoClickBlackPage:(BOOL)ansIgnorePageAutoClick {
    objc_setAssociatedObject(self, @selector(autoClickBlackPage), @(ansIgnorePageAutoClick), OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL)autoClickBlackPage {
    return [objc_getAssociatedObject(self, @selector(autoClickBlackPage)) boolValue];
}

@end

@implementation UIView (ANSView)

- (void)setAnsViewID:(NSString *)ansViewID {
    objc_setAssociatedObject(self, @selector(ansViewID), ansViewID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)ansViewID {
    return objc_getAssociatedObject(self, @selector(ansViewID));
}

- (void)setAutoClickBlackView:(BOOL)ignoreAutoClick {
    objc_setAssociatedObject(self, @selector(autoClickBlackView), @(ignoreAutoClick), OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL)autoClickBlackView {
    return [objc_getAssociatedObject(self, @selector(autoClickBlackView)) boolValue];
}

//static const char * ans_custom_props = "ans_custom_props";
//- (void)setAnsViewProperty:(NSDictionary *)ansViewCustomProps {
//    objc_setAssociatedObject(self, ans_custom_props, ansViewCustomProps, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//- (NSDictionary *)ansViewProperty {
//    return objc_getAssociatedObject(self, ans_custom_props);
//}

@end

@implementation AnalysysAgent

+ (void)setObserverListener:(id)observerListener {
    [[AnalysysSDK sharedManager] setObserverListener:observerListener];
}

+ (void)startWithConfig:(AnalysysAgentConfig *)config {
    [[AnalysysSDK sharedManager] startWithConfig:config];
}

+ (NSString *)SDKVersion {
    return [AnalysysSDK SDKVersion];
}

+ (void)monitorAppDelegate:(id<UIApplicationDelegate>)delegate launchOptions:(NSDictionary *)launchOptions {
    [[ANSAppStartSource sharedManager] startMonitorAppDelegate:delegate launchOptions:launchOptions];
}

#pragma mark - 服务器地址设置

+ (void)setUploadURL:(NSString *)uploadURL {
    [[AnalysysSDK sharedManager] setUploadURL:uploadURL];
}

+ (void)setVisitorDebugURL:(NSString *)visitorDebugURL {
    [[AnalysysSDK sharedManager] setVisitorDebugURL:visitorDebugURL];
}

+ (void)setVisitorConfigURL:(NSString *)configURL {
    [[AnalysysSDK sharedManager] setVisitorConfigURL:configURL];
}

#pragma mark - SDK发送策略

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

+ (void)setUploadNetworkType:(AnalysysNetworkType)networkType {
    [[AnalysysSDK sharedManager] setUploadNetworkType:networkType];
}
    
+ (void)cleanDBCache {
    [[AnalysysSDK sharedManager] cleanDBCache];
}
    
#pragma mark - 事件

+ (void)track:(NSString *)event {
    [AnalysysAgent track:event properties:nil];
}

+ (void)track:(NSString *)event properties:(NSDictionary *)properties {
    [[AnalysysSDK sharedManager] track:event properties:properties];
}

#pragma mark - 页面事件

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

+ (void)setPageViewWhiteListByPages:(NSSet<NSString *> *)controllers {
    [[AnalysysSDK sharedManager] setPageViewWhiteListByPages:controllers];
}

+ (void)setPageViewBlackListByPages:(NSSet<NSString *> *)controllers {
    [[AnalysysSDK sharedManager] setPageViewBlackListByPages:controllers];
}

+ (void)setIgnoredAutomaticCollectionControllers:(NSArray<NSString *> *)controllers {
    [[AnalysysSDK sharedManager] setIgnoredAutomaticCollectionControllers:controllers];
}

#pragma mark - 全埋点模块接口
+ (void)setAutoTrackClick:(BOOL)isAuto {
    [ANSAllBuryPoint allBuryPointAutoTrack:isAuto];
}

+ (void)setAutoClickBlackListByPages:(NSSet<NSString *> *)controllerNames {
    [[ANSAllBuryPoint sharedManager] setAutoClickBlackListByPages:controllerNames];
}

+ (void)setAutoClickBlackListByViewTypes:(NSSet<NSString *> *)viewNames {
    [[ANSAllBuryPoint sharedManager] setAutoClickBlackListByViewTypes:viewNames];
}

+ (void)setAutoClickWhiteListByPages:(NSSet<NSString *> *)controllerNames {
    [[ANSAllBuryPoint sharedManager] setAutoClickWhiteListByPages:controllerNames];
}

+ (void)setAutoClickWhiteListByViewTypes:(NSSet<NSString *> *)viewNames {
    [[ANSAllBuryPoint sharedManager] setAutoClickWhiteListByViewTypes:viewNames];
}

#pragma mark - 热图模块儿接口
+ (void)setAutomaticHeatmap:(BOOL)autoTrack {
    [[AnalysysSDK sharedManager] setAutomaticHeatmap:autoTrack];
}

+ (void)setHeatMapBlackListByPages:(NSSet<NSString *> *)controllerNames {
    [[AnalysysSDK sharedManager] setHeatmapIgnoreAutoClickByPage:controllerNames];
}

+ (void)setHeatMapWhiteListByPages:(NSSet<NSString *> *)controllerNames {
    [[AnalysysSDK sharedManager] setHeatmapAutoClickByPage:controllerNames];
}

#pragma mark - 崩溃模块接口
+ (void)reportException:(NSException *)exception {
    [ANSUncaughtExceptionHandler reportException:exception];
}

#pragma mark - 通用属性

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
    return [[AnalysysSDK sharedManager] getSuperPropertiesValue];
}

+ (id)getSuperProperty:(NSString *)superPropertyName {
    return [[AnalysysSDK sharedManager] getSuperProperty:superPropertyName];;
}

+ (NSDictionary *)getPresetProperties {
    return [[AnalysysSDK sharedManager] getPresetProperties];
}

#pragma mark - 用户信息相关

+ (void)identify:(NSString *)anonymousId {
    [[AnalysysSDK sharedManager] identify:anonymousId];
}

+ (void)alias:(NSString *)aliasId {
    [self alias:aliasId originalId:nil];
}

+ (void)alias:(NSString *)aliasId originalId:(NSString *)originalId {
    [[AnalysysSDK sharedManager] alias:aliasId originalId:originalId];
}

+ (NSString *)getDistinctId {
    return [[AnalysysSDK sharedManager] getDistinctId];
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

#pragma mark - 清除本地设置

+ (void)reset {
    [[AnalysysSDK sharedManager] reset];
}

#pragma mark - Hybrid 页面

+ (BOOL)setHybridModel:(id)webView request:(NSURLRequest *)request {
    return [[AnalysysSDK sharedManager] setHybridModel:webView request:request];
}

+ (void)resetHybridModel {
    [[AnalysysSDK sharedManager] resetHybridModel];
}


#pragma mark - 活动推送效果
+ (void)setPushProvider:(AnalysysPushProvider)provider pushID:(NSString *)pushID {
    [self setPushID:pushID provider:provider];
}

/** 设置推送平台及第三方推送标识 */
+ (void)setPushID:(NSString *)pushID provider:(AnalysysPushProvider)provider {
    [[AnalysysSDK sharedManager] setPushProvider:provider pushID:pushID];
}

/** 追踪活动推广 */
+ (void)trackCampaign:(id)userInfo isClick:(BOOL)isClick {
    [AnalysysAgent trackCampaign:userInfo isClick:isClick userCallback:nil];
}

/** 追踪活动推广，可回调用户自定义信息 */
+ (void)trackCampaign:(id)userInfo isClick:(BOOL)isClick userCallback:(void(^)(id campaignInfo))userCallback {
        [[AnalysysSDK sharedManager] trackCampaign:userInfo isClick:isClick userCallback:^(id  _Nonnull campaignInfo) {
            if (userCallback) {
                userCallback(campaignInfo);
            }
        }];
}


@end
