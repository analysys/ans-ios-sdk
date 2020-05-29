//
//  ANSDataCheckRouter.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/5/9.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSDataCheckRouter.h"

#import "ANSDataConfig.h"
#import "ANSDataCheckLog.h"
#import "ANSMediator.h"

@implementation ANSDataCheckRouter

+ (ANSDataCheckLog *)checkProperties:(NSDictionary **)superProperties type:(ANSPropertyType)type {
    ANSDataCheckLog *checkResult = nil;
    checkResult = [self checkPropertiesType:*superProperties];
    if (checkResult) {
        *superProperties = nil;
        return checkResult;
    }
    NSMutableDictionary *newProperty = nil;
    ANSDataConfig *dataConfig = [ANSDataConfig sharedManager];
    NSDictionary *properties = *superProperties;
    for (id key in properties.allKeys) {
        id propertyValue = properties[key];
        //  map-key校验
        checkResult = [self checkPropertyKey:key value:nil type:type checkRules:dataConfig.defaultContextKeyRules];
        if (checkResult && checkResult.resultType <= AnalysysResultSuccess) {
            //这里需要 copy 原来的 property 并remove 不合法的 key-value
            if (!newProperty) {
                newProperty = [NSMutableDictionary dictionaryWithDictionary:*superProperties];
            }
            //  不合法数据不再删除
//            [newProperty removeObjectForKey:key];
            continue;
        }
        //  map-value校验
        checkResult = [self checkPropertyKey:key value:propertyValue type:type checkRules:dataConfig.defaultContextValueRules];
        if (checkResult && checkResult.resultType == AnalysysResultPropertyValueFixed) {
            id valueFixed = checkResult.valueFixed;
            if (!newProperty) {
                newProperty = [NSMutableDictionary dictionaryWithDictionary:*superProperties];
            }
            if (valueFixed) {
                [newProperty setValue:valueFixed forKey:key];
            } else {
                [newProperty removeObjectForKey:key];
            }
        }
    };
    
    if (newProperty) {
        checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultPropertyValueFixed;
        checkResult.value = [properties copy];
        checkResult.valueFixed = [newProperty copy];
        *superProperties = [NSDictionary dictionaryWithDictionary:newProperty];
    }
    return checkResult;
}

+ (ANSDataCheckLog *)checkPropertyKey:(NSString *)key value:(id)value type:(ANSPropertyType)type checkRules:(NSArray *)funcList {
    ANSDataCheckLog *checkResult = nil;
    if (type == ANSPropertyIncrement) {
        if (value) {
            NSArray *incrementRules = [ANSDataConfig sharedManager].contextInfo[@"profile_increment"][ANSRulesCheckFuncList];
            funcList = incrementRules;
        }
    } else if(type == ANSPropertyAppend) {
        if (value) {
            NSArray *appendRules = [ANSDataConfig sharedManager].contextInfo[@"profile_append"][ANSRulesCheckFuncList];
            funcList = appendRules;
        }
    }
    
    NSArray *list = [funcList copy];
    for (NSString *func in list) {
        NSArray *array = [func componentsSeparatedByString:@"."];
        if (array.count == 2) {
            Class cls = NSClassFromString(array[0]);
            NSString *funcStr = array[1];
            if (cls) {
                NSArray *params = key ? (value ? @[key,value] : @[key]) : (value ? @[value] : @[]);
                checkResult = (ANSDataCheckLog *)[ANSMediator performTarget:cls action:funcStr params:params];
                if (checkResult) {
                    break;
                }
            }
        }
    }
    return checkResult;
}

#pragma mark - 部分配置中特殊参数检查

+ (ANSDataCheckLog *)checkSuperProperties:(NSDictionary **)superProperties {
    return [self checkProperties:superProperties type:ANSPropertyDefault];
}

+ (ANSDataCheckLog *)checkPropertiesType:(NSDictionary *)superProperties {
    ANSDataCheckLog *checkResult = nil;
    if (superProperties && ![superProperties isKindOfClass:NSDictionary.class]) {
        checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultTypeError;
        checkResult.keyWords = @"NSDictionary";
        checkResult.value = superProperties;
    }
    return checkResult;
}

+ (ANSDataCheckLog *)checkIncrementProperties:(NSDictionary **)incrementProperties {
    return  [self checkProperties:incrementProperties type:ANSPropertyIncrement];
}

+ (ANSDataCheckLog *)checkAppendProperties:(NSDictionary **)appendProperties {
    return  [self checkProperties:appendProperties type:ANSPropertyAppend];
}

+ (ANSDataCheckLog *)checkLengthOfIdentify:(NSString *)identify {
    //TODO: key = identify
    return [self checkPropertyKey:nil value:identify type:ANSPropertyDefault checkRules:ANSDataConfig.sharedManager.dataRules[@"identify"][ANSRulesCheckFuncList]];
}

+ (ANSDataCheckLog *)checkLengthOfAliasId:(NSString *)aliasId {
    //TODO: key = aliasId
    return [self checkPropertyKey:nil value:aliasId type:ANSPropertyDefault checkRules:ANSDataConfig.sharedManager.dataRules[@"alias"][ANSRulesCheckFuncList]];
}

+ (ANSDataCheckLog *)checkAliasOriginalId:(NSString *)originalId {
    //TODO: key = aliasOriginalId
    originalId = originalId ?: @"";
    return [self checkPropertyKey:nil value:originalId type:ANSPropertyDefault checkRules:ANSDataConfig.sharedManager.dataRules[@"aliasOriginalId"][ANSRulesCheckFuncList]];
}

+ (ANSDataCheckLog *)checkEvent:(NSString *)event{
    NSArray *checkList = [ANSDataConfig sharedManager].dataRules[@"track"][ANSRulesCheckFuncList];
    return [ANSDataCheckRouter checkPropertyKey:nil value:event type:ANSPropertyDefault checkRules:checkList];
}

@end
