//
//  AnalysysSDK.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANSConst.h"
#import "ANSDatabase.h"

@class AnalysysAgentConfig;

@protocol EventDataDelegate <NSObject>

@optional

/// 接收到用户属性回调
/// @param key 属性 key 值
/// @param value 属性 value 值
- (void)onUserProfile:(NSString *)key value:(NSString *)value;

/// 接收到事件回调
/// @param eventData 回调数据
- (void)onEventDataReceived:(id)eventData;

@end

@interface AnalysysSDK : NSObject


+ (instancetype)sharedManager;

@property (nonatomic, assign) BOOL isBackgroundActive;  //  是否后台激活
@property (nonatomic, assign) long long appDuration;    //  App本次运行时长
@property (nonatomic, weak) id<EventDataDelegate> delegate; // 事件监听代理

/**
注册事件监听对象

@param observerListener 事件监听对象
*/
- (void)setObserverListener:(id)observerListener;

/**
 通过配置初始化SDK

 @param config 配置信息
 */
- (void)startWithConfig:(AnalysysAgentConfig *)config;

/**
 SDK版本信息
 */
+ (NSString *)SDKVersion;

#pragma mark - 服务器地址设置

/**
 设置上传数据地址
 */
- (void)setUploadURL:(NSString *)uploadURL;

/**
 设置可视化websocket服务器地址
 */
- (void)setVisitorDebugURL:(NSString *)visitorDebugURL;

/**
 设置线上请求埋点配置的服务器地址
 */
- (void)setVisitorConfigURL:(NSString *)configURL;


#pragma mark - SDK发送策略

/**
 debug模式
 */
- (void)setDebugMode:(AnalysysDebugMode)debugMode;

- (AnalysysDebugMode)debugMode;

/**
 设置上传间隔时间，单位：秒
 */
- (void)setIntervalTime:(NSInteger)flushInterval;

/**
 数据累积"size"条数后触发上传
 */
- (void)setMaxEventSize:(NSInteger)flushSize;

/**
 本地缓存上限值
 */
- (void)setMaxCacheSize:(NSInteger)cacheSize;

- (NSInteger)maxCacheSize;

/**
 手动上传
 */
- (void)flush;

/// 设置数据网络上传策略
/// @param networkType 网络类型
- (void)setUploadNetworkType:(AnalysysNetworkType)networkType;
    
/// 清理数据库缓存
- (void)cleanDBCache;

#pragma mark - 点击事件

/**
 添加事件及附加属性
 */
- (void)track:(NSString *)event properties:(NSDictionary *)properties;

#pragma mark - 页面事件

/**
 页面跟踪及附加属性
 */
- (void)pageView:(NSString *)pageName properties:(NSDictionary *)properties;

/**
 SDK 页面自动采集
 */
- (void)autoPageView:(NSString *)pageName properties:(NSDictionary *)properties;

/**
 设置是否允许页面自动采集
 */
- (void)setAutomaticCollection:(BOOL)isAuto;

/**
 当前页面自动跟踪开关状态
 */
- (BOOL)isViewAutoTrack;

/**
 只采集部分页面
*/
- (void)setPageViewWhiteListByPages:(NSSet<NSString *> *)controllers;

/**
 忽略部分页面自动采集
*/
- (void)setPageViewBlackListByPages:(NSSet<NSString *> *)controllers;

/**
 忽略部分页面自动采集
 */
- (void)setIgnoredAutomaticCollectionControllers:(NSArray<NSString *> *)controllers;

#pragma mark - 热图模块儿接口

/**
 是否采集用户点击坐标
 
 @param autoTrack YES/NO
 */
- (void)setAutomaticHeatmap:(BOOL)autoTrack;

/**
 忽略部分页面上所有的点击事件

 仅在热图模式下生效

 @param controllerNames 控制器类名字符串数组
*/
- (void)setHeatmapIgnoreAutoClickByPage:(NSSet<NSString *> *)controllerNames;

/**
  只上报部分页面内点击事件
 
  仅在热图模式下生效
 
  @param controllerNames 控制器类名字符串数组
*/
- (void)setHeatmapAutoClickByPage:(NSSet<NSString *> *)controllerNames;

#pragma mark - 通用属性

/**
 注册通用属性
 */
- (void)registerSuperProperties:(NSDictionary *)superProperties;

/**
 添加单个通用属性
 */
- (void)registerSuperProperty:(NSString *)superPropertyName value:(id)superPropertyValue;

/**
 删除某个通用属性
 */
- (void)unRegisterSuperProperty:(NSString *)superPropertyName;

/**
 清除所有通用属性
 */
- (void)clearSuperProperties;

/**
 获取已注册通用属性
 */
- (NSDictionary *)getSuperPropertiesValue;

/**
 获取某个通用属性
 */
- (id)getSuperProperty:(NSString *)superPropertyName;


/**
 SDK预置属性
 */
- (NSDictionary *)getPresetProperties;


#pragma mark - 用户属性

/**
 匿名ID设置。小于255字符
 */
- (void)identify:(NSString *)anonymousId;

/**
 用户关联。小于255字符
 */
- (void)alias:(NSString *)aliasId originalId:(NSString *)originalId;

/**
 获取匿名ID
 
 @return 匿名ID
 */
- (NSString *)getDistinctId;

/**
 设置用户属性
 */
- (void)profileSet:(NSDictionary *)property;

- (void)profileSet:(NSString *)propertyName propertyValue:(id)propertyValue;


/**
 设置用户固有属性
 */
- (void)profileSetOnce:(NSDictionary *)property;

- (void)profileSetOnce:(NSString *)propertyName propertyValue:(id)propertyValue;


/**
 设置用户属性相对变化值
 */
- (void)profileIncrement:(NSDictionary<NSString*, NSNumber*> *)property;

- (void)profileIncrement:(NSString *)propertyName propertyValue:(NSNumber *)propertyValue;


/**
 增加列表类型的属性
 */
- (void)profileAppend:(NSDictionary *)property;

- (void)profileAppend:(NSString *)propertyName value:(id)propertyValue;

/** NSSet 的元素必须是 NSString 类型，否则，会忽略 */
- (void)profileAppend:(NSString *)propertyName propertyValue:(NSSet<NSString *> *)propertyValue;


/**
 删除某个用户属性
 */
- (void)profileUnset:(NSString *)propertyName;


/**
 删除当前用户的所有属性
 */
- (void)profileDelete;


#pragma mark - 清除本地设置

/**
 清除本地设置（anonymousId、aliasID、superProperties）
 */
- (void)reset;


#pragma mark - Hybrid 页面

/**
 监听webview
 */
- (BOOL)setHybridModel:(id)webView request:(NSURLRequest *)request;


/**
 重置UserAgent
 */
- (void)resetHybridModel;


#pragma mark - 消息推送

/**
 推送基本设置
 */
- (void)setPushProvider:(AnalysysPushProvider)provider pushID:(NSString *)pushID;

/**
 推送效果统计，可回调用户自定义信息
 */
- (void)trackCampaign:(id)userInfo isClick:(BOOL)isClick userCallback:(void(^)(id campaignInfo))userCallback;

#pragma mark - other

/**
 热图事件
 */
- (void)trackHeatMapWithSDKProperties:(NSDictionary *)sdkProperties;

/**
 页面是否忽略了自动采集
 
 @param className 类名
 @return bool
 */
- (BOOL)isIgnoreTrackWithClassName:(NSString *)className;

/**
 只采集部分页面

 @param className 类名
 @return bool
*/
- (BOOL)isTrackWithClassName:(NSString *)className;

/**
 $page_view 事件是否有白名单
 @return bool
*/
- (BOOL)hasPageViewWhiteList;

/**
 当前用户标识

 @return userId
 */
- (NSString *)getXwho;

/**
 本地存储信息获取
 
 @return properties
 */
- (NSDictionary *)getCommonProperties;


- (ANSDatabase *)getDBHelper;

- (void)saveUploadInfo:(NSDictionary *)dataInfo event:(NSString *)event handler:(void(^)(void))handler;
@end


