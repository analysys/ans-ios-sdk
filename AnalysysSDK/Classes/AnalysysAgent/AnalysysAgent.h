//
//  AnalysysAgent.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//


// ********************************
// ***** 当前 SDK 版本号：4.5.1 *****
// ********************************

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ANSConst.h"
#import "AnalysysAgentConfig.h"


/**
 * @protocol
 * 页面自动采集协议
 *
 * @abstract
 * 当页面开启自动采集时，追加页面自定义参数
 *
 * @discussion
 * 继承至UIViewController的子类，若遵循该协议，可将自定义页面的属性信息增加至$pageview事件中
 */
@protocol ANSAutoPageTracker <NSObject>

@optional

/**
 自定义页面属性信息，返回信息将自动增加至@pageview事件中

 @return 页面参数
 */
- (NSDictionary *)registerPageProperties;

/**
 自定义页面标识，返回信息将覆盖$url字段

 @return 页面标识
 */
- (NSString *)registerPageUrl;

@end

@interface UIViewController (ANSViewController)

/**
 是否忽略当前页面上所有的事件采集
 
 仅在全埋点生效

 默认为 NO
*/
@property (nonatomic, assign) BOOL autoClickBlackPage;

@end

@interface UIView (ANSView)

/**
 给控件添加控件ID
 
 仅在全埋点生效
*/
@property (nonatomic, copy) NSString* ansViewID;

/**
 是否忽略当前控件的事件采集
 
 仅在全埋点生效

 默认为 NO
*/
@property (nonatomic, assign) BOOL autoClickBlackView;

@end


/**
 * @class
 * AnalysysAgent 接口
 *
 * @abstract
 * 提供 AnalysysAgent 对外 API
 *
 * @discussion
 * 提供了包括基础配置、页面、事件、通用属性、用户属性、发送策略等相关功能。
 */
@interface AnalysysAgent : NSObject


#pragma mark - 基本配置

/**
注册事件监听对象

@param observerListener 事件监听对象
*/
+ (void)setObserverListener:(id)observerListener;

/**
 使用配置信息初始化SDK
 
 @param config 配置信息
 */
+ (void)startWithConfig:(AnalysysAgentConfig *)config;

/**
 SDK版本信息
 
 @return SDK版本
 */
+ (NSString *)SDKVersion;


/**
 跟踪App启动方式
 前提：必须实现相应启动方式的回调方法
 如：通过通知启动，则需实现通知相应不同版本的回调方法
 
 @param delegate 遵循<UIApplicationDelegate>协议的类
 @param launchOptions 启动参数
 */
+ (void)monitorAppDelegate:(id<UIApplicationDelegate>)delegate launchOptions:(NSDictionary *)launchOptions;

#pragma mark - 服务器地址设置

/**
 设置上传数据地址
 
 uploadURL：格式：http://host:port 或 https://host:port
 如：https://arkpaastest.analysys.cn:8089
 
 @param uploadURL 数据上传地址
 */
+ (void)setUploadURL:(NSString *)uploadURL;

/**
 设置可视化websocket服务器地址
 
 visitorDebugURL：格式：ws://host:port 或 wss://host:port 如：ws://arkpaastest.analysys.cn:9091
 
 @param visitorDebugURL 可视化地址
 */
+ (void)setVisitorDebugURL:(NSString *)visitorDebugURL;

/**
 设置线上请求埋点配置的服务器地址
 
 - configURL：格式：http://host:port 或 https://host:port 如：https://arkpaastest.analysys.cn:8089
 
 @param configURL 事件配置地址
 */
+ (void)setVisitorConfigURL:(NSString *)configURL;

#pragma mark - SDK发送策略

/**
 debug模式
 
 @param debugMode AnalysysDebugMode枚举
 */
+ (void)setDebugMode:(AnalysysDebugMode)debugMode;

+ (AnalysysDebugMode)debugMode;

/**
 设置上传间隔时间，单位：秒
 
 仅AnalysysDebugOff模式
 
 @param flushInterval 时间间隔(>=1)
 */
+ (void)setIntervalTime:(NSInteger)flushInterval;

/**
 数据累积"size"条数后触发上传
 
 仅AnalysysDebugOff模式
 
 @param size 数据条数(>=1)
 */
+ (void)setMaxEventSize:(NSInteger)size;

/**
 本地缓存上限值，最小值为100
 
 默认10000条，超过此数据默认清理最早的10条数据。
 
 @param size 最多缓存条数
 */
+ (void)setMaxCacheSize:(NSInteger)size;

+ (NSInteger)maxCacheSize;

/**
 手动上传
 
 若存在延迟，不会触发上传
 */
+ (void)flush;

/// 设置数据网络上传策略
/// 默认只要存在网络即会上传，不区分移动网络即WIFI网络
/// @param networkType 网络类型
+ (void)setUploadNetworkType:(AnalysysNetworkType)networkType;
    
/// 清除本地所有已缓存数据
+ (void)cleanDBCache;


#pragma mark - 点击事件

/**
 添加事件
 
 @param event 事件标识，必须以字母或'$'开头，只能包含：字母、数字、下划线和$，字母不区分大小写，最大长度是99字符，不支持乱码和中文
 */
+ (void)track:(NSString *)event;

/**
 添加事件及附加属性
 
 @param event 事件标识，同 track: 接口
 @param properties 自定义参数。key：同track:接口事件标识限制，最大长度是99字符；value：允许添加以下类型：NSString/NSNumber/NSArray<NSString*>/NSSet<NSString*>/NSDate/NSURL；
 */
+ (void)track:(NSString *)event properties:(NSDictionary *)properties;


#pragma mark - 页面事件

/**
 页面跟踪
 
 默认SDK跟踪所有页面，无需设置。
 
 @param pageName 页面标识，最大长度是255字符
 */
+ (void)pageView:(NSString *)pageName;

/**
 页面跟踪及附加属性
 
 @param pageName 页面标识，最大长度是255字符
 @param properties 自定义参数。同 track:properties: 属性限制
 */
+ (void)pageView:(NSString *)pageName properties:(NSDictionary *)properties;

/**
 设置是否允许页面自动采集
 
 SDK默认自动追踪页面切换
 
 @param isAuto 开关值，默认为YES打开，设置NO为关闭
 */
+ (void)setAutomaticCollection:(BOOL)isAuto;

/**
 当前页面自动跟踪开关状态
 
 @return 开关状态
 */
+ (BOOL)isViewAutoTrack;

/**
 设置页面统计白名单
*/
+ (void)setPageViewWhiteListByPages:(NSSet<NSString *> *)controllers;

/**
 设置页面统计黑名单
 
 @param controllers UIViewController类名字符串数组
 */
+ (void)setPageViewBlackListByPages:(NSSet<NSString *> *)controllers;

/**
 设置页面统计黑名单
 
 @param controllers UIViewController类名字符串数组
 */
+ (void)setIgnoredAutomaticCollectionControllers:(NSArray<NSString *> *)controllers __attribute__((deprecated("已过时！建议使用setPageViewBlackListByPages:接口")));

#pragma mark - 全埋点功能模块接口

/**
 设置全埋点事件是否允许自动采集
 
 @param isAuto 开关值，默认为NO关闭，设置YES为开
 */
+ (void)setAutoTrackClick:(BOOL)isAuto;

/**
 忽略部分页面上所有的点击事件

 仅在全埋点模式下生效

 @param controllerNames 控制器类名字符串数组
*/
+ (void)setAutoClickBlackListByPages:(NSSet<NSString *> *)controllerNames;

/**
  忽略某些类名控件点击事件
 
  仅在全埋点模式下生效
  
  @param viewNames UI控件类名字符串数组
*/
+ (void)setAutoClickBlackListByViewTypes:(NSSet<NSString *> *)viewNames;

/**
  只上报部分页面内点击事件
 
  仅在全埋点模式下生效
 
  @param controllerNames 控制器类名字符串数组
*/
+ (void)setAutoClickWhiteListByPages:(NSSet<NSString *> *)controllerNames;

/**
  只上报某些类名控件点击事件
 
  仅在全埋点模式下生效
 
  @param viewNames UI控件类名字符串数组
*/
+ (void)setAutoClickWhiteListByViewTypes:(NSSet<NSString *> *)viewNames;

#pragma mark - 热图功能模块接口

/**
 是否采集用户点击坐标

 @param autoTrack YES/NO
 */
+ (void)setAutomaticHeatmap:(BOOL)autoTrack;

/**
 忽略部分页面上所有的点击事件

 仅在热图模式下生效

 @param controllerNames 控制器类名字符串数组
*/
+ (void)setHeatMapBlackListByPages:(NSSet<NSString *> *)controllerNames;

/**
 只上报部分页面内点击事件

 仅在热图模式下生效

 @param controllerNames 控制器类名字符串数组
*/
+ (void)setHeatMapWhiteListByPages:(NSSet<NSString *> *)controllerNames;

#pragma mark - 崩溃收集功能模块接口
+ (void)reportException:(NSException *)exception;

#pragma mark - 通用属性

/**
 此部分属性将在所有触发事件中携带
 
 约束信息：
 属性名：必须以字母或'$'开头，只能包含：字母、数字、下划线和$，字母不区分大小写，最大长度是 99 字符，不支持乱码和中文
 
 属性值：必须为以下类型：NSString/NSNumber/NSArray<NSString*>/NSSet<NSString*>/NSDate/NSURL
 
 当多个属性中的key相同时，属性优先级：自定义属性 > 通用属性 > SDK自动采集属性。
 如：track事件，通用属性 中都包含"userLevel"字段
 registerSuperProperties: {@"userLevel":@"silver",@"userPhone":@"186***"}
 track:properties: {@"userLevel":@"glod",@"goods":@"iPhone X"}
 则track上传数据为：{@"userLevel":@"glod",@"goods":@"iPhone X",@"userPhone":@"186***"}
 
 @param superProperties 通用属性
 */
+ (void)registerSuperProperties:(NSDictionary *)superProperties;

/**
 添加单个通用属性
 
 value必须为以下类型：NSString/NSNumber/NSArray<NSString*>/NSSet<NSString*>/NSDate/NSURL。
 
 @param superPropertyName 最大长度是 99 字符
 @param superPropertyValue 属性值
 */
+ (void)registerSuperProperty:(NSString *)superPropertyName value:(id)superPropertyValue;

/**
 删除某个通用属性
 
 @param superPropertyName 属性ekey
 */
+ (void)unRegisterSuperProperty:(NSString *)superPropertyName;

/**
 清除所有通用属性
 */
+ (void)clearSuperProperties;

/**
 获取已注册通用属性
 
 @return 当前通用属性
 */
+ (NSDictionary *)getSuperProperties;

/**
 获取某个通用属性
 
 @param superPropertyName 属性key
 @return 属性值
 */
+ (id)getSuperProperty:(NSString *)superPropertyName;

/**
 SDK预置属性

 @return 所有预置属性
 */
+ (NSDictionary *)getPresetProperties;

#pragma mark - 用户属性

/**
 匿名ID设置。小于255字符
 
 @param anonymousId 匿名id
 */
+ (void)identify:(NSString *)anonymousId;


/// 用户关联。小于255字符
/// @param aliasId 当前用户标识
+ (void)alias:(NSString *)aliasId;

/**
 用户关联。小于255字符
 
 @param aliasId 当前用户标识
 @param originalId 原有用户标识
 */
+ (void)alias:(NSString *)aliasId originalId:(NSString *)originalId __attribute__((deprecated("已过时！建议使用alias:接口")));

/**
 获取匿名ID
 
 @return 匿名ID
 */
+ (NSString *)getDistinctId;

/**
 用户属性若无特殊说明，具有以下约束：
 属性名：必须以字母或'$'开头，只能包含：字母、数字、下划线和$，字母不区分大小写，最大长度是 99 字符，不支持乱码和中文
 属性值：必须为以下类型：NSString/NSNumber/NSArray<NSString*>/NSSet<NSString*>/NSDate/NSURL
 最多允许100个键值对
 */

/**
 设置用户属性
 
 @param property 用户信息
 */
+ (void)profileSet:(NSDictionary *)property;

+ (void)profileSet:(NSString *)propertyName propertyValue:(id)propertyValue;


/**
 设置用户固有属性
 
 同一个key只在首次设置时有效。如果之前存在，则覆盖，否则新创建。
 如：用户生日只允许设置一次。
 
 @param property Profile 的内容
 */
+ (void)profileSetOnce:(NSDictionary *)property;

+ (void)profileSetOnce:(NSString *)propertyName propertyValue:(id)propertyValue;


/**
 设置用户属性相对变化值
 
 property中，key为NSString类型，value为NSNumber类型
 
 @param property 属性
 */
+ (void)profileIncrement:(NSDictionary<NSString*, NSNumber*> *)property;

+ (void)profileIncrement:(NSString *)propertyName propertyValue:(NSNumber *)propertyValue;


/**
 增加列表类型的属性
 
 如果某个用户属性存在，则这次会被覆盖掉；不存在，则会创建
 
 @param property 属性字典
 */
+ (void)profileAppend:(NSDictionary *)property;

+ (void)profileAppend:(NSString *)propertyName value:(id)propertyValue;

/** NSSet 的元素必须是 NSString 类型，否则，会忽略 */
+ (void)profileAppend:(NSString *)propertyName propertyValue:(NSSet<NSString *> *)propertyValue;


/**
 删除某个用户属性
 
 @param propertyName Profile 名称
 */
+ (void)profileUnset:(NSString *)propertyName;


/**
 删除当前用户的所有属性
 */
+ (void)profileDelete;


#pragma mark - 清除本地设置

/**
 清除本地设置（anonymousId、aliasID、superProperties）
 */
+ (void)reset;


#pragma mark - Hybrid 页面

/**
 监听WKWebView
 
 @param request 请求对象
 @param webView WKWebView对象
 @return 统计是否完成
 */
+ (BOOL)setHybridModel:(id)webView request:(NSURLRequest *)request;


/**
 重置UserAgent
 */
+ (void)resetHybridModel;


#pragma mark - 消息推送

+ (void)setPushProvider:(AnalysysPushProvider)provider pushID:(NSString *)pushID __attribute__((deprecated("已过时！建议使用setPushID:provider:接口")));

/**
推送基本设置

@param pushID 第三方推送标识。如：极光的registrationID，个推的clientId，百度的channelid，小米的xmRegId
@param provider 推送提供方标识，目前支持 AnalysysPushProvider 枚举中的类型
*/
+ (void)setPushID:(NSString *)pushID provider:(AnalysysPushProvider)provider;

/**
 推送效果统计
 
 将推送回调的userInfo字典回传（如：极光推送），或jsonStr（如：个推的payloadMsg字符串）
 iOS10之后的接口：(UNNotificationResponse)response.notification.request.content.userInfo和(UNNotification)notification.request.content.userInfo
 
 若为点击活动通知：共包含以下四种行为：
 跳转应用指定页面：若使用UITabBarController、UINavigationController及其子类作为window.rootViewController的应用，则调用pushViewController:方法到相应页面；若使用UIViewController及其子类时，则调用presentViewController:方式模态推出，需用户在推出页面中添加取消按钮，并调用dismissViewControllerAnimated:方法返回页面。
 打开链接：>=iOS 9.0应用内浏览链接；否则使用浏览器打开链接；
 打开应用：仅调起应用；
 自定义行为：将自定义参数返回开发者
 
 @param userInfo 推送携带的参数信息
 @param isClick YES：用户点击通知  NO：接收到消息通知
 */
+ (void)trackCampaign:(id)userInfo isClick:(BOOL)isClick;


/**
 推送效果统计，可回调用户自定义信息
 
 参考 trackCampaign:isClick: 方法
 
 @param userInfo 推送携带的参数信息
 @param isClick YES：用户点击通知  NO：接收到消息通知
 @param userCallback 将解析后的用户下发活动信息回调用户
 */
+ (void)trackCampaign:(id)userInfo isClick:(BOOL)isClick userCallback:(void(^)(id campaignInfo))userCallback;



@end


