//
//  ANSDataConfig.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/18.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSDataConfig.h"
#import "ANSBundleUtil.h"

NSString *const ANSTemplateContext = @"xcontext";
NSString *const ANSTemplateOuter = @"outer";
NSString *const ANSTemplateCheckList = @"propertyCheckList";
NSString *const ANSRulesReservedKeyword = @"ReservedKeywords";
NSString *const ANSRulesValueType = @"valueType";
NSString *const ANSRulesValue = @"value";
NSString *const ANSRulesCheckFuncList = @"checkFuncList";
NSString *const ANSRulesContextKey = @"contextKey";
NSString *const ANSRulesContextValue = @"contextValue";

@implementation ANSDataConfig

static NSString *const ANSTemplateBaseKey = @"base";

+ (instancetype)sharedManager {
    static id singleInstance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        if (!singleInstance) {
            singleInstance = [[self alloc] init] ;
        }
    });
    return singleInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dataTemplate = [ANSDataConfig getTemplateInfoWithBundles:@[@"DefaultTemplateData", @"CMBTemplateData", @"HeatMapTemplateData"]];
        _dataRules = [ANSDataConfig getFieldRulesWithBundles:@[@"DefaultFieldRules", @"CMBFieldRules", @"HeatMapFieldRules"]];
        _contextInfo = _dataRules[ANSTemplateContext];
        _defaultContextKeyRules = _contextInfo[ANSRulesContextKey][ANSRulesCheckFuncList];
        _defaultContextValueRules = _contextInfo[ANSRulesContextValue][ANSRulesCheckFuncList];
    }
    return self;
}

- (NSArray *)propertyCheckListWithEvent:(NSString *)event {
    return _dataTemplate[event][ANSTemplateCheckList];
}

/** xcontext中预置属性列表 */
//- (NSSet *)allPrePropertyKeys {
//    NSMutableDictionary *templateInfo = [ANSDataConfig getTemplateInfoWithBundles:@[@"DefaultTemplateData"]];
//    NSMutableArray *allPreProperties = [NSMutableArray array];
//    for (NSString *templateKey in templateInfo.allKeys) {
//        NSArray *xcontextKeys = _dataTemplate[templateKey][ANSTemplateContext];
//        [allPreProperties addObjectsFromArray:xcontextKeys];
//    }
//    NSSet *preProperties = [NSSet setWithArray:allPreProperties];
//    return preProperties;
//}

#pragma mark - 接口

/**
 加载所有配置模板信息
 1. SDK默认模板数据
 2. 用户自定义模板数据
 
 @param bundles bundle名称
 @return 模板信息
 */
+ (id)getTemplateInfoWithBundles:(NSArray *)bundles {
    NSMutableDictionary *allTemplate = [NSMutableDictionary dictionary];
    for (NSString *templateFileName in bundles) {
        NSDictionary *templateInfo = [ANSBundleUtil loadConfigsWithFileName:templateFileName fileType:@"json"];
        allTemplate = [self mergeTemplateA:allTemplate withTemplateB:templateInfo];
    }
    if (allTemplate.allKeys.count == 0) {
        return nil;
    }
    
    [self mergeAllTemplate:allTemplate];
    
    return [allTemplate copy];
}

/** 合并base到各模块 */
+ (void)mergeAllTemplate:(NSMutableDictionary *)allTemplate {
    NSDictionary *baseInfo = [allTemplate objectForKey:ANSTemplateBaseKey];
    [allTemplate removeObjectForKey:ANSTemplateBaseKey];
    [allTemplate enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSMutableDictionary *moduleInfo = [NSMutableDictionary dictionaryWithDictionary:[allTemplate objectForKey:key]];
        [moduleInfo setValue:baseInfo[ANSTemplateOuter] forKey:ANSTemplateOuter];
        NSMutableArray *xcontextArray = [NSMutableArray arrayWithArray:moduleInfo[ANSTemplateContext]];
        [xcontextArray addObjectsFromArray:baseInfo[ANSTemplateContext]];
        [moduleInfo setValue:[NSSet setWithArray:xcontextArray].allObjects forKey:ANSTemplateContext];
        [allTemplate setValue:moduleInfo forKey:key];
    }];
}

/** 基础模板合并 */
+ (id)mergeTemplateA:(NSDictionary *)templateA withTemplateB:(NSDictionary *)templateB {
    if (templateA.allKeys.count == 0) {
        return [NSMutableDictionary dictionaryWithDictionary:templateB];
    }
    NSMutableDictionary *allTemplate = [NSMutableDictionary dictionaryWithDictionary:templateA];
    
    for (NSString *keyB in templateB.allKeys) {
        if ([keyB isEqualToString:ANSTemplateBaseKey]) {
            NSMutableArray *outerArray = [NSMutableArray arrayWithArray:allTemplate[keyB][ANSTemplateOuter]];
            NSMutableArray *xcontextArray = [NSMutableArray arrayWithArray:allTemplate[keyB][ANSTemplateContext]];

            NSArray *templateBOuter = templateB[keyB][ANSTemplateOuter];;
            [outerArray addObjectsFromArray:templateBOuter];
            
            NSArray *templateBXcontext = templateB[keyB][ANSTemplateContext];;
            [xcontextArray addObjectsFromArray:templateBXcontext];
            
            [allTemplate setValue:[NSMutableDictionary dictionaryWithObjectsAndKeys:outerArray,ANSTemplateOuter,xcontextArray,ANSTemplateContext, nil] forKey:keyB];
        } else {
            if ([allTemplate.allKeys containsObject:keyB]) {
                NSMutableArray *moduleXcontextArray = [NSMutableArray arrayWithArray:allTemplate[keyB][ANSTemplateContext]];
                NSArray *templateBXcontext = templateB[keyB][ANSTemplateContext];
                [moduleXcontextArray addObjectsFromArray:templateBXcontext];
                
                NSMutableArray *modulePropertyArray = [NSMutableArray arrayWithArray:allTemplate[keyB][ANSTemplateCheckList]];
                NSArray *templateBPropertyArray = templateB[keyB][ANSTemplateCheckList];
                [modulePropertyArray addObjectsFromArray:templateBPropertyArray];
                
                [allTemplate setValue:[NSMutableDictionary dictionaryWithObjectsAndKeys:moduleXcontextArray,ANSTemplateContext,modulePropertyArray,ANSTemplateCheckList, nil] forKey:keyB];
            } else {
                [allTemplate setValue:templateB[keyB] forKey:keyB];
            }
        }
    }
    
    return allTemplate;
}

/**
 加载所有字段配置规则
 
 @param bundles bundle名称
 @return 规则集合
 */
+ (id)getFieldRulesWithBundles:(NSArray *)bundles {
    NSMutableDictionary *allRules = [NSMutableDictionary dictionary];
    for (NSString *ruleFileName in bundles) {
        NSDictionary *fieldRules = [ANSBundleUtil loadConfigsWithFileName:ruleFileName fileType:@"json"];
        allRules = [self mergeRuleA:allRules withRuleB:fieldRules];
    }
    
    return allRules;
}

/** 规则合并 */
+ (id)mergeRuleA:(NSDictionary *)ruleA withRuleB:(NSDictionary *)ruleB {
    if (ruleA.allKeys.count == 0) {
        return ruleB;
    }
    NSMutableDictionary *allRules = [NSMutableDictionary dictionaryWithDictionary:ruleA];
    
    for (NSString *key in ruleB.allKeys) {
        if ([key isEqualToString:ANSRulesReservedKeyword]) {
            NSMutableArray *keywords = [NSMutableArray arrayWithArray:ruleA[key]];
            [keywords addObjectsFromArray:ruleB[key]];
            [allRules setValue:keywords forKey:key];
        } else if ([key isEqualToString:ANSTemplateContext]) {
            NSMutableDictionary *context = [NSMutableDictionary dictionaryWithDictionary:allRules[key]];
            [context addEntriesFromDictionary:ruleB[key]];
            [allRules setValue:context forKey:ANSTemplateContext];
        } else {
            [allRules setValue:ruleB[key] forKey:key];
        }
    }
    
    return allRules;
}

@end
