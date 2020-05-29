//
//  ANSDataProcessing.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSDataProcessing.h"
#import "ANSMediator.h"
#import "ANSConst+private.h"
#import "ANSDataCheckLog.h"
#import "AnalysysLogger.h"
#import "ANSDataCheckRouter.h"
#import "ANSDataConfig.h"
#import "AnalysysSDK.h"

@implementation ANSDataProcessing

#pragma mark - 事件接口
+ (NSDictionary *)processAppCrashProperties:(NSDictionary *)properties {
    ANSDataCheckLog *checkResult = nil;
    NSDictionary *dict = [self fillTemplate:ANSEventCrash action:ANSEventCrash sdkProperties:nil userProperties:properties errLog:&checkResult];
    if (checkResult) {
        ANSBriefWarning(@"%@",[checkResult messageDisplay]);
    }
    return dict;
}

+ (NSDictionary *)processAppStartProperties:(NSDictionary *)properties {
    ANSDataCheckLog *checkResult = nil;
    NSDictionary *dict = [self fillTemplate:ANSEventAppStart action:ANSEventAppStart sdkProperties:nil userProperties:properties errLog:&checkResult];
    if (checkResult) {
        ANSBriefWarning(@"%@",[checkResult messageDisplay]);
    }
    return dict;
}

+ (NSDictionary *)processAppEnd {
    ANSDataCheckLog *checkResult = nil;
    NSDictionary *dict = [self fillTemplate:ANSEventAppEnd action:ANSEventAppEnd sdkProperties:nil userProperties:nil errLog:&checkResult];
    if (checkResult) {
        ANSBriefWarning(@"%@",[checkResult messageDisplay]);
    }
    return dict;
}

+ (NSDictionary *)processTrack:(NSString *)track properties:(NSDictionary *)properties {
    return [self fillTemplate:ANSEventTrack action:track sdkProperties:nil userProperties:properties];
}

+ (NSDictionary *)processPageProperties:(NSDictionary *)pageProperties SDKProperties:(NSDictionary *)sdkProperties {
    return [self fillTemplate:ANSEventPageView action:ANSEventPageView sdkProperties:sdkProperties userProperties:pageProperties];
}

+ (NSDictionary *)processAliasSDKProperties:(NSDictionary *)sdkProperties {
    return [self fillTemplate:ANSEventAlias action:ANSEventAlias sdkProperties:sdkProperties userProperties:nil];
}

+ (NSDictionary *)processProfileSetProperties:(NSDictionary *)properties {
    return [self fillTemplate:ANSProfileSetXXX action:ANSEventProfileSet sdkProperties:nil userProperties:properties];
}

+ (NSDictionary *)processProfileSetOnceProperties:(NSDictionary *)properties SDKProperties:(NSDictionary *)sdkProperties {
    return [self fillTemplate:ANSProfileSetXXX action:ANSEventProfileSetOnce sdkProperties:sdkProperties userProperties:properties];
}

+ (NSDictionary *)processProfileIncrementProperties:(NSDictionary *)properties {
    return [self fillTemplate:ANSProfileSetXXX action:ANSEventProfileIncrement sdkProperties:nil userProperties:properties];
}

+ (NSDictionary *)processProfileAppendProperties:(NSDictionary *)properties {
    return [self fillTemplate:ANSProfileSetXXX action:ANSEventProfileAppend sdkProperties:nil userProperties:properties];
}

+ (NSDictionary *)processProfileUnsetWithSDKProperties:(NSDictionary *)sdkProperties {
    return [self fillTemplate:ANSProfileSetXXX action:ANSEventProfileUnset sdkProperties:sdkProperties userProperties:nil];
}

+ (NSDictionary *)processProfileDelete {
    return [self fillTemplate:ANSProfileSetXXX action:ANSEventProfileDelete sdkProperties:nil userProperties:nil];
}

+ (NSDictionary *)processSDKEvent:(NSString *)track properties:(NSDictionary *)properties {
    return [self fillTemplate:ANSEventTrack action:track sdkProperties:properties userProperties:nil];
}

+ (NSDictionary *)processInstallationSDKProperties:(NSDictionary *)sdkProperties {
    return [self fillTemplate:ANSEventInstallation action:ANSEventInstallation sdkProperties:sdkProperties userProperties:nil];
}

+ (NSDictionary *)processHeatMapWithSDKProperties:(NSDictionary *)sdkProperties  {
    return [self fillTemplate:ANSEventHeatMap action:ANSEventHeatMap sdkProperties:sdkProperties userProperties:nil];
}

#pragma mark - 内部方法

/**
 根据事件类型获取对应数据模板，并填充数据、校验
 
 @param templateName 模板名称
 @param action xwhat
 @param sdkProperties SDK附加参数
 @param userProperties 用户传入参数
 */
+ (NSDictionary *)fillTemplate:(NSString *)templateName
                        action:(id)action
                 sdkProperties:(NSDictionary *)sdkProperties
                userProperties:(NSDictionary *)userProperties {
    ANSDataCheckLog *checkResult = nil;
    return [self fillTemplate:templateName action:action sdkProperties:sdkProperties userProperties:userProperties errLog:&checkResult];
}

+ (NSDictionary *)fillTemplate:(NSString *)templateName
                        action:(id)action
                 sdkProperties:(NSDictionary *)sdkProperties
                userProperties:(NSDictionary *)userProperties
                        errLog:(ANSDataCheckLog **)checkResult {
    
    ANSDataConfig *dataConfig = [ANSDataConfig sharedManager];
    NSDictionary *actionTemplate = dataConfig.dataTemplate[templateName];
    if (actionTemplate == nil) {
        *checkResult = [[ANSDataCheckLog alloc]init];
        (*checkResult).remarks = @"Please add config resource: AnalysysAgent.bundle !";
        ANSBriefWarning(@"%@",[*checkResult messageDisplay]);
        return nil;
    }
    
    if (userProperties && ![userProperties isKindOfClass:NSDictionary.class]) {
        *checkResult = [[ANSDataCheckLog alloc] init];
        (*checkResult).resultType = AnalysysResultTypeError;
        (*checkResult).keyWords = @"NSDictionary";
        (*checkResult).value = userProperties;
        ANSBriefWarning(@"%@",[*checkResult messageDisplay]);
    }
    
    if (![userProperties isKindOfClass:NSDictionary.class]) {
        userProperties = [NSDictionary dictionary];
    }
    
    if (![sdkProperties isKindOfClass:NSDictionary.class]) {
        sdkProperties = [NSDictionary dictionary];
    }
    
    NSMutableDictionary *uploadInfo = [NSMutableDictionary dictionary];
    // 1. 填充并校验模板中数据
    NSArray *outerKeys = actionTemplate[ANSTemplateOuter];
    for (NSString *outerFieldName in outerKeys) {
        // 查找对应模块
        if ([actionTemplate.allKeys containsObject:outerFieldName]) {
            // 1.2 填充并校验内层模板数据
            NSMutableDictionary *contextInfo = [NSMutableDictionary dictionary];
            NSArray *contextKeys = actionTemplate[outerFieldName];
            for (NSString *contextFieldName in contextKeys) {
                NSDictionary *fieldRules = dataConfig.dataRules[outerFieldName][contextFieldName];
                id fieldValue = [self getValueWithFieldRules:fieldRules andAciton:action key:outerFieldName error:checkResult];
                if (*checkResult != nil) {
                    ANSBriefWarning(@"%@",[*checkResult messageDisplay]);
                    return nil;
                }
                [contextInfo setValue:fieldValue forKey:contextFieldName];
                [uploadInfo setValue:contextInfo forKey:outerFieldName];
            }
        } else {
            //  1.1 填充并校验外层模板数据
            id outerValue =[self getValueWithFieldRules:dataConfig.dataRules[outerFieldName] andAciton:action key:outerFieldName error:checkResult];
            if (*checkResult != nil ) {
                ANSBriefWarning(@"%@",[*checkResult messageDisplay]);
                return nil;
            }
            [uploadInfo setValue:outerValue forKey:outerFieldName];
        }
    }
    
    NSMutableDictionary *innerUserProperties = [NSMutableDictionary dictionaryWithDictionary:userProperties];
    NSMutableDictionary *innerSDKProperties = [NSMutableDictionary dictionaryWithDictionary:sdkProperties];
    // 添加需要检测map-value的字段
    for (NSString *fieldName in [dataConfig propertyCheckListWithEvent:action]) {
        id uploadValue = uploadInfo[ANSTemplateContext][fieldName];
        if (uploadValue) {
            [innerUserProperties setValue:uploadValue forKey:fieldName];
        }
    }
    
    // 2. 数据合并(目前仅有xcontext结构)
    NSMutableDictionary *contextDic = uploadInfo[ANSTemplateContext];
    // 2.1 合并外部SDK自动采集数据
    [contextDic addEntriesFromDictionary:innerSDKProperties];
    // 2.2 剔除自动采集数据中value字符串为空的数据
    NSMutableDictionary *tempContextDic = [NSMutableDictionary dictionary];
    [contextDic enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        if ([value isKindOfClass:NSString.class]) {
            NSString *valueString = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (valueString != nil && valueString.length > 0) {
                [tempContextDic setValue:value forKey:key];
            }
        }
    }];
    [contextDic addEntriesFromDictionary:[tempContextDic mutableCopy]];
    
    // 3. 其他设置
    // 3.1 添加全局变量
    if (![templateName isEqualToString:ANSEventAlias] && ![templateName isEqualToString:ANSProfileSetXXX]) {
        [contextDic addEntriesFromDictionary:[[AnalysysSDK sharedManager] getSuperPropertiesValue]];
    }
    
    // 4 用户自定义参数检查
    if ([innerUserProperties isKindOfClass:NSDictionary.class] && innerUserProperties.count) {
        ANSDataCheckLog *retCheckResult = [ANSDataCheckRouter checkProperties:&innerUserProperties type:ANSPropertyDefault];
        if (retCheckResult && retCheckResult.resultType < AnalysysResultSuccess) {
            ANSBriefWarning(@"%@",[retCheckResult messageDisplay]);
            *checkResult = retCheckResult;
        }
    }
    // 4.1 合并用户数据
    [contextDic addEntriesFromDictionary:innerUserProperties];
    
    return uploadInfo;
}

/** 通过字段规则获取相应值并校验 */
+ (id)getValueWithFieldRules:(NSDictionary *)ruleDic andAciton:(id)value key:(NSString *)key error:(ANSDataCheckLog **)checkResult {
    // 1. 填充数据
    NSInteger getType = [ruleDic[ANSRulesValueType] integerValue];
    id dataValue ;
    switch (getType) {
        case 0: {
            //  通过方法获取数据
            NSString *funcStr = ruleDic[ANSRulesValue];
            NSArray *array = [funcStr componentsSeparatedByString:@"."];
            if (array.count == 2) {
                Class cls = NSClassFromString(array[0]);
                NSString *funcStr = array[1];
                if (cls) {
                    if ([cls respondsToSelector:@selector(sharedManager)]) {
                        id sharedInstance = [ANSMediator performTarget:cls action:@"sharedManager"];
                        dataValue = [ANSMediator performTarget:sharedInstance action:funcStr params:nil];
                    } else {
                        dataValue = [ANSMediator performTarget:cls action:funcStr params:nil];
                    }
                }
            }
        }
            break;
        case 1: {
            //  使用配置默认值
            dataValue = ruleDic[ANSRulesValue];
        }
            break;
        case 2: {
            //  传入值
            if (value) {
                dataValue = value;
            }
        }
            break;
        default:
            break;
    }
    
    // 2. 规则数据校验
    NSArray *checkFuncList = ruleDic[ANSRulesCheckFuncList];
    if (checkFuncList) {
        *checkResult = [ANSDataCheckRouter checkPropertyKey:nil value:dataValue type:ANSPropertyDefault checkRules:checkFuncList];
    }
    return dataValue;
}

@end
