//
//  ANSDataProcessing.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ANSDataConfig.h"

/**
 context中属性值检测规则类型

 - ANSPropertyDefault: 默认检查规则
 - ANSPropertyIncrement: $profile_increment 值检测规则
 - ANSPropertyAppend: $profile_append 值检测规则
 */
typedef NS_ENUM(NSInteger, ANSPropertyType) {
    ANSPropertyDefault = 0,
    ANSPropertyIncrement,
    ANSPropertyAppend
};

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

//  数据模板
@property (nonatomic, strong) NSDictionary *dataTemplate;
//  数据规则
@property (nonatomic, strong) NSDictionary *dataRules;

+ (instancetype)sharedManager;

#pragma mark *** 事件接口 ***

/**
 App启动

 @return 启动数据
 */
- (NSDictionary *)processAppStart;

/**
 App关闭

 @return 关闭数据
 */
- (NSDictionary *)processAppEnd;

/**
 track事件

 @param track 事件名称
 @param properties 自定义信息
 @return track数据
 */
- (NSDictionary *)processTrack:(NSString *)track properties:(NSDictionary *)properties;

/**
 页面数据

 @param pageProperties 自定义信息
 @param sdkProperties sdk采集信息
 @return 页面数据
 */
- (NSDictionary *)processPageProperties:(NSDictionary *)pageProperties SDKProperties:(NSDictionary *)sdkProperties;

/**
 身份信息

 @param sdkProperties sdk采集信息
 @return 身份数据
 */
- (NSDictionary *)processAliasSDKProperties:(NSDictionary *)sdkProperties;

/**
 profile_set信息

 @param properties 自定义信息
 @return profile_set数据
 */
- (NSDictionary *)processProfileSetProperties:(NSDictionary *)properties;

/**
 profile_set_once信息
 
 @param properties 自定义信息
 @param sdkProperties sdk采集信息
 @return profile_set_once数据
 */
- (NSDictionary *)processProfileSetOnceProperties:(NSDictionary *)properties SDKProperties:(NSDictionary *)sdkProperties;

/**
 profile_increment信息

 @param properties 自定义信息
 @return profile_increment数据
 */
- (NSDictionary *)processProfileIncrementProperties:(NSDictionary *)properties;

/**
 profile_append信息

 @param properties 自定义数据
 @return profile_append数据
 */
- (NSDictionary *)processProfileAppendProperties:(NSDictionary *)properties;

/**
 profile_unset信息

 @param sdkProperties sdk采集信息
 @return profile_unset数据
 */
- (NSDictionary *)processProfileUnsetWithSDKProperties:(NSDictionary *)sdkProperties;

/**
 profile_delete信息

 @return profile_delete数据
 */
- (NSDictionary *)processProfileDelete;


/**
 SDK track事件

 @param track 事件名称
 @param properties 参数
 @return 上传信息
 */
- (NSDictionary *)processSDKEvent:(NSString *)track properties:(NSDictionary *)properties;

/**
 热图数据

 @return heatmap
 */
- (NSDictionary *)processHeatMap;


#pragma mark *** 部分配置中特殊参数检查 ***

/**
 context属性key合法性校验

 @param key key
 @return 是否合法
 */
- (BOOL)isValidOfpropertyKey:(NSString *)key;

/**
 context属性k-v合法性校验

 @param properties k-v结构
 @return 是否合法
 */
- (BOOL)isValidOfProperties:(NSDictionary *)properties;

/**
 profile_increment k-v校验

 @param properties 自定义数据
 @return 是否合法
 */
- (BOOL)isValidOfIncrementProperties:(NSDictionary *)properties;

/**
 profile_append k-v校验

 @param properties 自定义数据
 @return 是否合法
 */
- (BOOL)isValidOfAppendProperties:(NSDictionary *)properties;

/**
 匿名id规则检查

 @param Identify 标识
 @return 是否合法
 */
- (BOOL)isValidOfIdentify:(NSString *)Identify;

/**
 aliasid检查

 @param aliasId aliasId
 @return 是否合法
 */
- (BOOL)isValidOfAliasId:(NSString *)aliasId;

/**
 alias_original_id检查

 @param originalId originalId
 @return 是否合法
 */
- (BOOL)isValidOfAliasOriginalId:(NSString *)originalId;


@end


