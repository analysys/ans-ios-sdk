//
//  ANSJsonUtil.h
//  AnalysysAgent
//
//  Created by analysys on 2018/2/6.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class
 * ANSJsonUtil
 *
 * @abstract
 * json数据处理
 *
 * @discussion
 * 处理json及对象间转换
 */

@interface ANSJsonUtil : NSObject


/**
 转换Object为Json data

 @param obj 需要转换的对象
 @return 转换后的结果
 */
+ (NSData *)jsonSerializeWithObject:(id)obj;

/**
 将对象转换为JSON允许类型

 @param obj 对象
 @return 转换结果
 */
+ (id)convertToJsonObjectWithObject:(id)obj;

/**
 json转字典

 @param jsonStr json
 @return 字典
 */
+ (NSDictionary *)convertToMapWithString:(NSString *)jsonStr;

/**
 字典转Json

 @param object 对象
 @return json
 */
+ (NSString *)convertToStringWithObject:(id)object;


@end


