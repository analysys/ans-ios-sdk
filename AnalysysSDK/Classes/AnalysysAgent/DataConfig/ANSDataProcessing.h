//
//  ANSDataProcessing.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * @class
 * ANSDataProcessing
 *
 * @abstract
 * 数据拼装、数据合法性校验
 *
 * @discussion
 * 根据数据模板配置，进行拼装
 * 根据数据规则配置，校验字段合法性
 */

@interface ANSDataProcessing : NSObject


#pragma mark - 事件接口

/**
App崩溃

@return 启动数据
*/
+ (NSDictionary *)processAppCrashProperties:(NSDictionary *)properties;

/**
 App启动

 @return 启动数据
 */
+ (NSDictionary *)processAppStartProperties:(NSDictionary *)properties;

/**
 App关闭

 @return 关闭数据
 */
+ (NSDictionary *)processAppEnd;

/**
 track事件

 @param track 事件名称
 @param properties 自定义信息
 @return track数据
 */
+ (NSDictionary *)processTrack:(NSString *)track properties:(NSDictionary *)properties;

/**
 页面数据

 @param pageProperties 自定义信息
 @param sdkProperties sdk采集信息
 @return 页面数据
 */
+ (NSDictionary *)processPageProperties:(NSDictionary *)pageProperties SDKProperties:(NSDictionary *)sdkProperties;

/**
 身份信息

 @param sdkProperties sdk采集信息
 @return 身份数据
 */
+ (NSDictionary *)processAliasSDKProperties:(NSDictionary *)sdkProperties;

/**
 profile_set信息

 @param properties 自定义信息
 @return profile_set数据
 */
+ (NSDictionary *)processProfileSetProperties:(NSDictionary *)properties;

/**
 profile_set_once信息
 
 @param properties 自定义信息
 @param sdkProperties sdk采集信息
 @return profile_set_once数据
 */
+ (NSDictionary *)processProfileSetOnceProperties:(NSDictionary *)properties SDKProperties:(NSDictionary *)sdkProperties;

/**
 profile_increment信息

 @param properties 自定义信息
 @return profile_increment数据
 */
+ (NSDictionary *)processProfileIncrementProperties:(NSDictionary *)properties;

/**
 profile_append信息

 @param properties 自定义数据
 @return profile_append数据
 */
+ (NSDictionary *)processProfileAppendProperties:(NSDictionary *)properties;

/**
 profile_unset信息

 @param sdkProperties sdk采集信息
 @return profile_unset数据
 */
+ (NSDictionary *)processProfileUnsetWithSDKProperties:(NSDictionary *)sdkProperties;

/**
 profile_delete信息

 @return profile_delete数据
 */
+ (NSDictionary *)processProfileDelete;


/**
 SDK track事件

 @param track 事件名称
 @param properties 参数
 @return 上传信息
 */
+ (NSDictionary *)processSDKEvent:(NSString *)track properties:(NSDictionary *)properties;

/**
 渠道追踪

 @param sdkProperties 额外信息
 @return 上传信息
 */
+ (NSDictionary *)processInstallationSDKProperties:(NSDictionary *)sdkProperties;

/**
 热图数据

 @param sdkProperties SDK采集数据
 @return heatmap
 */
+ (NSDictionary *)processHeatMapWithSDKProperties:(NSDictionary *)sdkProperties;



@end


