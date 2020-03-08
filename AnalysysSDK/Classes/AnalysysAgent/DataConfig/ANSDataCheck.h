//
//  ANSDataCheck.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSUInteger const ANSPropertyValueWarningLength = 255;
static NSUInteger const ANSPropertyValueMaxLength = 8191;
static NSUInteger const ANSPropertySetCapacity = 100;

/**
 * @class
 * ANSDataCheck
 *
 * @abstract
 * 对数据配置中带有校验规则的数据进行校验
 *
 * @discussion
 * 该类中的方法名称必须与规则配置文件 checkFuncList 中一一对应
 * 如：ANSDataCheck.getAppId
 */

@class ANSDataCheckLog;
@interface ANSDataCheck : NSObject

/** appkey校验 */
+ (ANSDataCheckLog *)checkAppKey:(NSString *)appKey;

/** xwho校验 */
+ (ANSDataCheckLog *)checkXwho:(NSString *)xwho;

/** 保留字段校验 */
+ (ANSDataCheckLog *)checkReservedKey:(NSString *)word;

/** xwhat字符串长度校验 */
+ (ANSDataCheckLog *)checkLengthOfXwhat:(NSString *)xwhat;

/** property.key是否为字符串类型 */
+ (ANSDataCheckLog *)checkTypeOfPropertyKey:(id)key;

/** property.key长度校验 */
+ (ANSDataCheckLog *)checkLengthOfPropertyKey:(NSString *)key;

/** xwho 字符串类型检查 */
+ (ANSDataCheckLog *)checkCharsOfXwho:(NSString *)xwho;

/** 匿名id合法性检查 */
+ (ANSDataCheckLog *)checkLengthOfIdentify:(NSString *)anonymousId;

/** aliasId是否合法 */
+ (ANSDataCheckLog*)checkLengthOfAliasId:(NSString *)aliasId;

/** originalId检查 */
+ (ANSDataCheckLog *)checkAliasOriginalId:(NSString *)originalId;

/** 检查 自定义属性value值 */
+(ANSDataCheckLog *)checkPropertyValueWithKey:(NSString *)key value:(id)value;

/** property.value类型检查 */
+ (ANSDataCheckLog *)checkTypeOfPropertyValueWithKey:(NSString *)key  value:(id )value;

/** 检查profile_increment.value */
+ (ANSDataCheckLog *)checkTypeOfIncrementPropertyValueWithKey:(NSString *)key value:(id)value;

/** 检查profile_append.value */
+ (ANSDataCheckLog *)checkTypeOfAppendPropertyValueWithKey:(NSString *)key value:(id)value;


@end

