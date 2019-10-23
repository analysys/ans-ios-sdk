//
//  ANSDataCheckRouter.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/5/9.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@class ANSConsoleLog;
@interface ANSDataCheckRouter : NSObject


/**
 自定义属性校验 key-value
 
 @param type 分类
 */
+ (ANSConsoleLog *)checkProperties:(NSDictionary **)superProperties type:(ANSPropertyType)type;

/**
 value校验
 
 @param value 校验对象
 @param funcList 方法列表字符串
 */
+ (ANSConsoleLog *)checkPropertyKey:(NSString *)key value:(id)value type:(ANSPropertyType)type checkRules:(NSArray *)funcList;

#pragma mark - 部分配置中特殊参数检查

/**
 检测通用property合法性
 
 必须初始化ANSCheckResult对象中extraInfo
 */
+ (ANSConsoleLog *)checkSuperProperties:(NSDictionary **)superProperties;

/**
 profile_increment k-v校验
 
 必须初始化ANSCheckResult对象中extraInfo
 */
+ (ANSConsoleLog *)checkIncrementProperties:(NSDictionary **)incrementProperties;

/**
 profile_append k-v校验
 
 必须初始化ANSCheckResult对象中extraInfo
 */
+ (ANSConsoleLog *)checkAppendProperties:(NSDictionary **)appendProperties;

/**
 匿名id规则检查
 
 @param identify 标识
 */
+ (ANSConsoleLog *)checkLengthOfIdentify:(NSString *)identify;

/**
 aliasid检查
 
 @param aliasId aliasId
 */
+ (ANSConsoleLog *)checkLengthOfAliasId:(NSString *)aliasId;

/**
 alias_original_id检查
 
 @param originalId originalId
 */
+ (ANSConsoleLog *)checkAliasOriginalId:(NSString *)originalId;

/**
 event 校验
 
 @param event 事件名
 @return ANSConsoleLog
 */
+ (ANSConsoleLog *)checkEvent:(NSString *)event;



@end


