//
//  AnalysysAgent.h
//  AnalysysAgent
//
//  Created by analysys on 2018/2/3.
//  Copyright © 2018年 analysys. All rights reserved.
//


// ********************************
// ***** 当前 SDK 版本号：4.1.1.2 *****
// ********************************


#import <Foundation/Foundation.h>


/*
 Debug模式，上线时使用 AnalysysDebugOff
 - AnalysysDebugOff: 关闭Debug模式
 - AnalysysDebugOnly: 打开Debug模式，但该模式下发送的数据仅用于调试，不进行数据导入
 - AnalysysDebugButTrack: 打开Debug模式，并入库计算
*/
typedef NS_ENUM(NSInteger, AnalysysDebugMode) {
    AnalysysDebugOff = 0,
    AnalysysDebugOnly = 1,
    AnalysysDebugButTrack = 2
};

/**
 数据上传加密类型

 - AnalysysEncryptAES: AES加密
 */
typedef NS_ENUM(NSInteger, AnalysysEncryptType) {
    AnalysysEncryptAES = 1,
};


/**
 推送类型
 
 - AnalysysPushJiGuang: 极光推送
 - AnalysysPushGeTui: 个推推送
 - AnalysysPushBaiDu: 百度推送
 - AnalysysPushXiaoMi: 小米推送
 */
typedef NS_ENUM(NSInteger, AnalysysPushProvider) {
    AnalysysPushJiGuang = 0,
    AnalysysPushGeTui,
    AnalysysPushBaiDu,
    AnalysysPushXiaoMi
};



#define AnalysysConfig [AnalysysAgentConfig shareInstance]

/**
 * @class
 * @abstract SDK 基础配置信息
 */

@interface AnalysysAgentConfig : NSObject


/**
 获取 AnalysysConfig 对象

 @return AnalysysConfig 实例
 */
+ (instancetype)shareInstance;


//  AppKey
@property (nonatomic, copy) NSString *appKey;

//  渠道标识，默认为“App Store”
@property (nonatomic, copy) NSString *channel;

/**
 统一域名：包含数据上传和可视化
 
 - 只需填写域名或IP部分，数据上传及可视化数据配置下发地址默认使用 HTTPS 协议，可视化前端使用 WSS 协议。如：arkpaastest.analysys.cn
 */
@property (nonatomic, copy) NSString *baseUrl;

//  是否追踪新用户的首次属性，默认为 YES
@property (nonatomic, assign) BOOL autoProfile;

//  数据上传加密类型
@property (nonatomic, assign) AnalysysEncryptType encryptType;


@end




/**
 * @class
 * @abstract 主要提供 AnalysysAgent 对外 API
 */

@interface AnalysysAgent : NSObject


#pragma mark *** 基本配置 ***


/**
 使用配置信息初始化SDK

 @param config 配置信息
 @return AnalysysAgent实例
 */
+ (AnalysysAgent *)startWithConfig:(AnalysysAgentConfig *)config;


/**
 初始化SDK
 
 - 统一域名：包含数据上传和可视化
 - baseURL只需填写域名或IP部分，数据上传及可视化数据配置下发地址默认使用HTTPS协议，可视化前端使用WSS协议。如：arkpaastest.analysys.cn

 @param appKey AppKey
 @param channel 渠道，默认为“App Store”
 @param baseURL 基础域名
 @return AnalysysAgent实例
 */
+ (AnalysysAgent *)startWithAppKey:(NSString *)appKey
                           channel:(NSString *)channel
                           baseURL:(NSString *)baseURL;


/**
 初始化SDK
 
 @param appKey AppKey
 @param channel 渠道，默认为“App Store”
 @param baseURL 基础域名
 @param autoProfile 是否追踪新用户的首次属性，默认autoProfile为YES
 @return AnalysysAgent实例
 */
+ (AnalysysAgent *)startWithAppKey:(NSString *)appKey
                           channel:(NSString *)channel
                           baseURL:(NSString *)baseURL
                       autoProfile:(BOOL)autoProfile;


/**
 SDK版本信息

 @return SDK版本
 */
+ (NSString *)SDKVersion;


#pragma mark *** 服务器地址设置 ***

/**
 设置上传数据地址
 
 - uploadURL 格式：http://host:port 或 https://host:port 如：https://arkpaastest.analysys.cn:8089
 
 @param uploadURL 数据上传地址
 */
+ (void)setUploadURL:(NSString *)uploadURL;


/**
 设置可视化websocket服务器地址
 
 - visitorDebugURL 格式：ws://host:port 或 wss://host:port 如：ws://arkpaastest.analysys.cn:9091

 @param visitorDebugURL 可视化地址
 */
+ (void)setVisitorDebugURL:(NSString *)visitorDebugURL;


/**
 设置线上请求埋点配置的服务器地址
 
 - configURL 格式：http://host:port 或 https://host:port 如：https://arkpaastest.analysys.cn:8089

 @param configURL 事件配置地址
 */
+ (void)setVisitorConfigURL:(NSString *)configURL;


#pragma mark *** SDK发送策略 ***

/**
 debug模式

 @param debugMode AnalysysDebugMode枚举
 */
+ (void)setDebugMode:(AnalysysDebugMode)debugMode;

+ (AnalysysDebugMode)debugMode;

/**
 设置上传间隔时间，单位：秒.
 仅AnalysysDebugOff模式或非WiFi环境下生效

 @param flushInterval 时间间隔(>=1)
 */
+ (void)setIntervalTime:(NSInteger)flushInterval;


/**
 数据累积"size"条数后触发上传.
 仅AnalysysDebugOff模式或非WiFi环境下生效
 
 @param size 数据条数(>=1)
 */
+ (void)setMaxEventSize:(NSInteger)size;


/**
 本地缓存上限值
 默认10000条，超过此数据默认清理最早的100条数据。

 @param size 最多缓存条数
 */
+ (void)setMaxCacheSize:(NSInteger)size;

+ (NSInteger)maxCacheSize;


/**
 手动上传
 
 - 若无数据则不触发上传
 - 若存在策略延迟，不会触发上传
 */
+ (void)flush;


#pragma mark *** 点击事件 ***

/**
 添加事件
 
 @param event 事件标识，必须以字母或'$'开头，只能包含：字母、数字、下划线和$，字母不区分大小写，$开头为预置事件/属性，最大长度是99字符，不支持乱码和中文
 */
+ (void)track:(NSString *)event;


/**
 添加事件及附加属性

 @param event 事件标识，同 track: 接口
 @param properties 自定义参数，允许添加以下类型：NSString/NSNumber/NSArray<NSString*>/NSSet<NSString*>/NSDate/NSURL；
 且key为字符串，同 track: 接口事件标识限制，最大长度是125字符
 */
+ (void)track:(NSString *)event properties:(NSDictionary *)properties;


#pragma mark *** 页面事件 ***

/**
 页面跟踪
 默认SDK跟踪所有页面，无需设置。
 
 @param pageName 页面标识，最大长度是255字符
 */
+ (void)pageView:(NSString *)pageName;


/**
 页面跟踪及附加属性

 @param pageName 页面标识，最大长度是255字符
 @param properties 自定义参数，允许添加以下类型：NSString/NSNumber/NSArray<NSString*>/NSSet<NSString*>/NSDate/NSURL；
 且key为字符串，同 track: 接口事件标识限制，最大长度是125字符
 */
+ (void)pageView:(NSString *)pageName properties:(NSDictionary *)properties;


/**
 设置是否允许页面自动采集
 
 - SDK默认自动追踪页面切换功能，可通过该接口设置是否允许页面自动跟踪
 
 @param isAuto 开关值,默认为YES打开,设置NO为关闭
 */
+ (void)setAutomaticCollection:(BOOL)isAuto;


/**
 当前SDK是否允许页面自动跟踪
 
 @return 开关状态
 */
+ (BOOL)isViewAutoTrack;


/**
 忽略部分页面自动采集
 
 - 仅在已设置为autoTrack模式下生效
 
 @param controllers UIViewController类名字符串数组
 */
+ (void)setIgnoredAutomaticCollectionControllers:(NSArray<NSString *> *)controllers;


#pragma mark *** 通用属性 ***

/**
 注册通用属性
 此属性中值将在所有触发事件都会携带
 
 约束信息：
 - 属性名称：必须以字母或'$'开头，只能包含：字母、数字、下划线和$，字母不区分大小写，$开头为预置事件/属性，最大长度是125字符，不支持乱码和中文
 - 属性值：类型必须为以下类型：NSString/NSNumber/NSArray<NSString*>/NSSet<NSString*>/NSDate/NSURL
 - 当用户自定义的Properties，superProperties和SDK自动采集的设备Properties具有相同key时，优先级如下：
 Properties > superProperties > 设备Properties
 - 当此接口多次调用时，具有相同key的value将被覆盖，不同key的value将会merge，例如：
 第一次设置为：{@"key1":@"1",@"key2":@"2"}
 第二次设置为：{@"key1":@"abc",@"key3":@"efd"}
 则merge后结果为：{@"key1":@"abc",@"key2":@"2",@"key3":@"efd"}
 - SDK将此结果保存，每次数据上传都会携带上传。
 
 @param superProperties 传入需要merge到通用属性的字典信息
 */
+ (void)registerSuperProperties:(NSDictionary *)superProperties;


/**
 添加单个通用属性
 
 - value类型必须为以下类型：NSString/NSNumber/NSArray<NSString*>/NSSet<NSString*>/NSDate/NSURL。
 
 @param superPropertyName key值
 @param superPropertyValue value对象
 */
+ (void)registerSuperProperty:(NSString *)superPropertyName value:(id)superPropertyValue;


/**
 删除单个通用属性
 
 @param superPropertyName 属性key
 */
+ (void)unRegisterSuperProperty:(NSString *)superPropertyName;


/**
 清除所有通用属性
 */
+ (void)clearSuperProperties;


/**
 获取通用属性
 
 @return 通用属性副本
 */
+ (NSDictionary *)getSuperProperties;


/**
 获取某个通用属性
 
 @param superPropertyName key值
 @return key对应的通用属性值
 */
+ (id)getSuperProperty:(NSString *)superPropertyName;


#pragma mark *** 用户属性 ***

/**
 用户ID设置，长度大于0且小于255字符
 
 @param distinctId 标识
 */
+ (void)identify:(NSString *)distinctId;


/**
 用户关联，长度大于0且小于255字符

 @param aliasId 新distinctID替换原有originalId
 @param originalId 原始id。该变量将会映射到aliasId，即：后续id是aliasId
        如果变量为空，则使用本地distinctId(来源于identify:)
 */
+ (void)alias:(NSString *)aliasId originalId:(NSString *)originalId;


/**
 用户属性设置，字典若无特殊说明，具有以下约束：

 - 字典key为字符串，必须以字母或'$'开头，只能包含：字母、数字、下划线和$，字母不区分大小写，$开头为预置事件/属性，最大长度是125字符，不支持乱码和中文
 - 允许添加value类型为非自定义对象类型，通常为 NSString/NSNumber/NSArray<NSString*>/NSSet<NSString*>/NSDate/NSURL
 - 属性字典中最多允许100个键值对
 */

/**
 设置用户属性
 
 - 如果之前存在，则覆盖，否则，新创建
 
 @param property 用户信息
 */
+ (void)profileSet:(NSDictionary *)property;

+ (void)profileSet:(NSString *)propertyName propertyValue:(id)propertyValue;


/**
 设置用户固有属性
 
 - 只在首次设置时有效的属性。如果之前存在，则覆盖，否则新创建
 
 @param property Profile 的内容
 */
+ (void)profileSetOnce:(NSDictionary *)property;

+ (void)profileSetOnce:(NSString *)propertyName propertyValue:(id)propertyValue;


/**
 设置用户属性相对变化值
 
 - 只能对 NSNumber 类型的用户属性调用这个接口，否则会被忽略
 - 如果这个用户属性之前不存在，则初始值当做0来处理
 - property字典中，key是NSString类型，value是NSNumber类型
 
 @param property 属性字典
 */
+ (void)profileIncrement:(NSDictionary *)property;

+ (void)profileIncrement:(NSString *)propertyName propertyValue:(NSNumber *)propertyValue;


/**
 增加列表类型的属性

 - 如果某个用户属性存在，则这次会被覆盖掉；不存在，则会创建
 
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


#pragma mark *** 清除本地设置 ***

/**
 清除本地设置（distinctID、aliasID、superProperties）
 */
+ (void)reset;


#pragma mark *** 消息推送 ***

/**
 推送基本设置

 @param provider 推送提供方标识，目前只 AnalysysPushProvider 枚举中的类型
 @param pushID 第三方推送标识。如：极光的registrationID，个推的clientId，百度的channelid，小米的xmRegId
 */
+ (void)setPushProvider:(AnalysysPushProvider)provider pushID:(NSString *)pushID;


/**
 推送效果统计
 
 - 将推送回调的userInfo字典回传（如：极光推送），或jsonStr（如：个推的payloadMsg字符串）
 - iOS10之后的接口：(UNNotificationResponse)response.notification.request.content.userInfo和(UNNotification)notification.request.content.userInfo

 若为点击活动通知：共包含以下四种行为：
 - 跳转应用指定页面：若使用UITabBarController、UINavigationController及其子类作为window.rootViewController的应用，则调用pushViewController:方法到相应页面；若使用UIViewController及其子类时，则调用presentViewController:方式模态推出，需用户在推出页面中添加取消按钮，并调用dismissViewControllerAnimated:方法返回页面。
 - 打开链接：>=iOS 9.0应用内浏览链接；否则使用浏览器打开链接；
 - 打开应用：仅调起应用；
 - 自定义行为：将自定义参数返回开发者
 
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


#pragma mark *** Hybrid 页面 ***

/**
 SDK监听拦截URL

 @param request 请求对象
 @param webView UIWebView/WKWebView对象
 @return 统计是否完成
 */
+ (BOOL)setHybridModel:(id)webView request:(NSURLRequest *)request;


/**
 重置UserAgent
 */
+ (void)resetHybridModel;


@end



