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

extern NSString *const ANSTemplateContext;
extern NSString *const ANSTemplateCheckList;
extern NSString *const ANSTemplateOuter;
extern NSString *const ANSRulesReservedKeyword;
extern NSString *const ANSRulesValueType;
extern NSString *const ANSRulesValue;
extern NSString *const ANSRulesCheckFuncList;

+ (instancetype)sharedManager;


@property (nonatomic, strong) NSDictionary *dataTemplate;   //  数据模板
@property (nonatomic, strong) NSDictionary *dataRules;  // 所有规则
@property (nonatomic, strong) NSDictionary *contextInfo;  // context规则
@property (nonatomic, strong) NSArray *defaultContextKeyRules; // 通用key规则
@property (nonatomic, strong) NSArray *defaultContextValueRules; // 通用value规则
@property (nonatomic, strong) NSArray *propertyCheckList; // 需要map结构value检测的字段


/** 获取需要检测的map-value */
- (NSArray *)propertyCheckListWithEvent:(NSString *)event;



@end


