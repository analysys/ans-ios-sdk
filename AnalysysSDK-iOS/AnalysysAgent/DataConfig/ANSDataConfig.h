//
//  ANSDataConfig.h
//  TestFramework
//
//  Created by SoDo on 2019/2/18.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class
 * ANSDataConfig
 *
 * @abstract
 * 读取配置信息
 *
 * @discussion
 * 读取默认及自定义上传数据模板并合并
 * 读取默认及自定义数据校验规则并合并
 */

@interface ANSDataConfig : NSObject

extern NSString *const ANSConfigContext;

extern NSString *const ANSConfigTemplateOuter;

extern NSString *const ANSConfigRulesReservedKeyword;
extern NSString *const ANSConfigRulesValueType;
extern NSString *const ANSConfigRulesValue;
extern NSString *const ANSConfigRulesCheckFuncList;
extern NSString *const ANSConfigRulesContextKey;
extern NSString *const ANSConfigRulesContextValue;

/**
 加载所有配置模板信息
 1. SDK默认模板数据
 2. 用户自定义模板数据
 
 @return 模板信息
 */
+ (id)allTemplateData;

/**
 加载所有字段配置规则

 @return 规则集合
 */
+ (id)allFieldRules;



@end


