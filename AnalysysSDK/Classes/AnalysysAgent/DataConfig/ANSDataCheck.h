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

@class ANSConsoleLog;
@interface ANSDataCheck : NSObject

/** appkey校验 */
+ (ANSConsoleLog *)checkAppKey:(NSString *)appKey;

/** xwho校验 */
+ (ANSConsoleLog *)checkXwho:(NSString *)xwho;

/** 保留字段校验 */
+ (ANSConsoleLog *)checkReservedKey:(NSString *)word;

/** xwho字符串长度校验 */
+ (ANSConsoleLog *)checkLengthOfXwho:(NSString *)xwho;

/** property.key是否为字符串类型 */
+ (ANSConsoleLog *)checkTypeOfPropertyKey:(id)key;

/** property.key长度校验 */
+ (ANSConsoleLog *)checkLengthOfPropertyKey:(NSString *)key;

/** xwho 字符串类型检查 */
+ (ANSConsoleLog *)checkCharsOfXwho:(NSString *)xwho;

/** 匿名id合法性检查 */
+ (ANSConsoleLog *)checkLengthOfIdentify:(NSString *)anonymousId;

/** aliasId是否合法 */
+ (ANSConsoleLog*)checkLengthOfAliasId:(NSString *)aliasId;

/** originalId检查 */
+ (ANSConsoleLog *)checkAliasOriginalId:(NSString *)originalId;

/** 检查 自定义属性value值 */
+(ANSConsoleLog *)checkPropertyValueWithKey:(NSString *)key value:(id)value;

/** property.value类型检查 */
+ (ANSConsoleLog *)checkTypeOfPropertyValueWithKey:(NSString *)key  value:(id )value;

/** 检查profile_increment.value */
+ (ANSConsoleLog *)checkTypeOfIncrementPropertyValueWithKey:(NSString *)key value:(id)value;

/** 检查profile_append.value */
+ (ANSConsoleLog *)checkTypeOfAppendPropertyValueWithKey:(NSString *)key value:(id)value;


@end

