//
//  ANSDataConfig.m
//  TestFramework
//
//  Created by SoDo on 2019/2/18.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSDataConfig.h"
#import "ANSBundleUtil.h"

NSString *const ANSConfigContext = @"xcontext";

NSString *const ANSConfigTemplateOuter = @"outer";

NSString *const ANSConfigRulesReservedKeyword = @"ReservedKeywords";
NSString *const ANSConfigRulesValueType = @"valueType";
NSString *const ANSConfigRulesValue = @"value";
NSString *const ANSConfigRulesCheckFuncList = @"checkFuncList";
NSString *const ANSConfigRulesContextKey = @"contextKey";
NSString *const ANSConfigRulesContextValue = @"contextValue";

@implementation ANSDataConfig

#pragma mark *** public ***

static NSString *const templateBase = @"base";

#pragma mark *** 接口 ***

+ (id)allTemplateData {
    NSArray *templateArray = @[@"DefaultTemplateData"];
    NSMutableDictionary *allTemplate = [NSMutableDictionary dictionary];
    for (NSString *templateFileName in templateArray) {
        NSDictionary *tempalteInfo = [ANSBundleUtil loadConfigsWithFileName:templateFileName fileType:@"json"];
        allTemplate = [[self mergeToTemplate:allTemplate withTemplate:tempalteInfo] mutableCopy];
    }
    [allTemplate removeObjectForKey:templateBase];
    return [allTemplate copy];
}

+ (id)mergeToTemplate:(NSDictionary *)dTemplate withTemplate:(NSDictionary *)cTemplate {
    NSMutableDictionary *allTemplateDic = [NSMutableDictionary dictionary];
    // 1. 处理公共部分
    NSDictionary *dBaseInfo = dTemplate[templateBase];
    NSMutableArray *dOuterArray = [NSMutableArray arrayWithArray:dBaseInfo[ANSConfigTemplateOuter]];
    NSMutableArray *dContextArray = [NSMutableArray arrayWithArray:dBaseInfo[ANSConfigContext]];
    if (cTemplate) {
        NSDictionary *cBaseInfo = cTemplate[templateBase];
        //  1.1 合并基础部分
        NSArray *cOuterArray = cBaseInfo[ANSConfigTemplateOuter];
        if (cOuterArray.count) {
            [dOuterArray addObjectsFromArray:cOuterArray];
        }
        //  1.2 合并xcontext部分
        NSArray *cContextArray = cBaseInfo[ANSConfigContext];
        if (cContextArray.count) {
            [dContextArray addObjectsFromArray:cContextArray];
        }
    }
    
    // 2. 合并自定义各个事件
    // 2.1 以默认模板合并
    NSDictionary *mergedTemplate = [self mergeTemplate:cTemplate
                                            toTemplate:dTemplate
                                        baseOuterArray:dOuterArray
                                      baseContextArray:dContextArray
                                               forKeys:dTemplate.allKeys];
    [allTemplateDic addEntriesFromDictionary:mergedTemplate];
    
    // 2.2 自定义多出模板
    NSMutableSet *cSet = [NSMutableSet setWithArray:cTemplate.allKeys];
    NSMutableSet *dSet = [NSMutableSet setWithArray:dTemplate.allKeys];
    [cSet minusSet:dSet];
    if (cSet.count) {
        NSDictionary *minusTemplate = [self mergeTemplate:cTemplate
                                               toTemplate:nil
                                           baseOuterArray:dOuterArray
                                         baseContextArray:dContextArray
                                                  forKeys:cSet.allObjects];
        [allTemplateDic addEntriesFromDictionary:minusTemplate];
    }
    //NSLog(@"%@",[self convertMapToJson:allTemplateDic]);
    
    return [allTemplateDic copy];
}

+ (id)allFieldRules {
    NSArray *rulesArray = @[@"DefaultFieldRules"];
    NSMutableDictionary *allRules = [NSMutableDictionary dictionary];
    for (NSString *ruleFileName in rulesArray) {
        NSDictionary *fieldRules = [ANSBundleUtil loadConfigsWithFileName:ruleFileName fileType:@"json"];
        allRules = [self mergeToFieldRules:allRules withFieldRules:fieldRules];
    }
    
    return allRules;
}

+ (id)mergeToFieldRules:(NSDictionary *)dFieldRules withFieldRules:(NSDictionary *)cFieldRules {
    // 1. 合并保留关键字
    NSMutableArray *reservedKeywords = [NSMutableArray arrayWithArray:dFieldRules[ANSConfigRulesReservedKeyword]];
    NSArray *cReservedKeywords = cFieldRules[ANSConfigRulesReservedKeyword];
    if (cReservedKeywords.count) {
        [reservedKeywords addObjectsFromArray:cReservedKeywords];
    }
    // 2. 外层数据合并
    // 2.1 以默认模板为基准合并
    NSMutableDictionary *outerRules = [NSMutableDictionary dictionary];
    for (NSString *key in dFieldRules.allKeys) {
        if (![key isEqualToString:ANSConfigRulesReservedKeyword] && ![key isEqualToString:ANSConfigContext]) {
            outerRules[key] = dFieldRules[key];
            NSDictionary *tmpRules = cFieldRules[key];
            if (tmpRules.allKeys.count) {
                outerRules[key] = tmpRules;
            }
        }
    }
    // 2.2 合并自定义多出字段
    NSMutableSet *cOuterSet = [NSMutableSet setWithArray:cFieldRules.allKeys];
    NSMutableSet *dOuterSet = [NSMutableSet setWithArray:dFieldRules.allKeys];
    [cOuterSet minusSet:dOuterSet];
    for (NSString *key in cOuterSet) {
        if (![key isEqualToString:ANSConfigRulesReservedKeyword] && ![key isEqualToString:ANSConfigContext]) {
            outerRules[key] = cFieldRules[key];
        }
    }
    
    // 3. xcontext内层数据合并
    NSDictionary *dContext = dFieldRules[ANSConfigContext];
    NSDictionary *cContext = cFieldRules[ANSConfigContext];
    NSMutableDictionary *allContext = [NSMutableDictionary dictionaryWithDictionary:dContext];
    // 3.1 以默认模板为基准合并
    for (NSString *key in allContext.allKeys) {
        NSDictionary *tmpContext = cContext[key];
        if (tmpContext.allKeys) {
            allContext[key] = tmpContext;
        }
    }
    // 3.2 合并自定义多出字段
    NSMutableSet *cContextSet = [NSMutableSet setWithArray:cContext.allKeys];
    NSMutableSet *dContextSet = [NSMutableSet setWithArray:dContext.allKeys];
    [cContextSet minusSet:dContextSet];
    for (NSString *key in cContextSet) {
        allContext[key] = cContext[key];
    }
    
    NSMutableDictionary *allFieldRules = [NSMutableDictionary dictionary];
    allFieldRules[ANSConfigRulesReservedKeyword] = reservedKeywords;
    [allFieldRules addEntriesFromDictionary:outerRules];
    allFieldRules[ANSConfigContext] = allContext;
    
    //NSLog(@"%@", [self convertMapToJson:allFieldRules]);
    
    return allFieldRules;
}


#pragma mark *** private ***

//+ (NSString *)convertMapToJson:(NSMutableDictionary *)map {
//    @try {
//        NSError *parseError = nil;
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:map options:NSJSONWritingPrettyPrinted error:&parseError];
//        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    } @catch (NSException *exception) {
//        NSLog(@"Convert map to json failure: %@", exception);
//    }
//    return nil;
//}

/**
 合并模板信息

 @param template 要合并的模板
 @param targetTemplate 合并到的目标模板
 @param outerArray 公共outer字段
 @param contextArray 公共context字段
 @param keys 遍历的key数组
 @return 合并后数据
 */
+ (NSDictionary *)mergeTemplate:(NSDictionary *)template
                     toTemplate:(NSDictionary *)targetTemplate
                 baseOuterArray:(NSArray *)outerArray
               baseContextArray:(NSArray *)contextArray
                        forKeys:(NSArray *)keys {
    NSMutableDictionary *mergedTemplateDic = [NSMutableDictionary dictionary];
    @try {
        for (NSString *key in keys) {
            NSMutableArray *pOuterArray = [NSMutableArray arrayWithArray:outerArray];
            NSArray *dDetailOuter = targetTemplate[key][ANSConfigTemplateOuter];
            if (dDetailOuter.count) {
                [pOuterArray addObjectsFromArray:dDetailOuter];
            }
            NSArray *cDetailOuter = template[key][ANSConfigTemplateOuter];
            if (cDetailOuter.count) {
                [pOuterArray addObjectsFromArray:cDetailOuter];
            }
            
            NSMutableArray *pContextArray = [NSMutableArray arrayWithArray:contextArray];
            NSArray *dDetailContext = targetTemplate[key][ANSConfigContext];
            if (dDetailContext.count) {
                [pContextArray addObjectsFromArray:dDetailContext];
            }
            NSArray *cDetailContext = template[key][ANSConfigContext];
            if (cDetailContext.count) {
                [pContextArray addObjectsFromArray:cDetailContext];
            }
            
            mergedTemplateDic[key] = @{
                                       ANSConfigTemplateOuter: [NSSet setWithArray:pOuterArray].allObjects,
                                       ANSConfigContext: [NSSet setWithArray:pContextArray].allObjects
                                       };
        }
    } @catch (NSException *exception) {
        
    }
    return mergedTemplateDic;
}




@end
