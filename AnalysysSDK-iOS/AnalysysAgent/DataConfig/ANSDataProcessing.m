//
//  ANSDataProcessing.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSDataProcessing.h"
#import "ANSMediator.h"
#import "ANSConst.h"
#import "AnalysysSDK.h"
#import "ANSFileManager.h"

@implementation ANSDataProcessing {
    NSDictionary *_contextInfo;
    NSArray *_defaultContextKeyRules; // 通用key规则
    NSArray *_defaultContextValueRules; // 通用value规则
    NSInteger _userKeysLimit; //  用户map限制
    NSInteger _allKeysCount; //  上传map限制
}

+ (instancetype)sharedManager {
    static id singleInstance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        singleInstance = [[self alloc] init] ;
    });
    return singleInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dataTemplate = [ANSDataConfig allTemplateData];
        _dataRules = [ANSDataConfig allFieldRules];
        
        _contextInfo = _dataRules[ANSConfigContext];
        _defaultContextKeyRules = _contextInfo[ANSConfigRulesContextKey][ANSConfigRulesCheckFuncList];
        _defaultContextValueRules = _contextInfo[ANSConfigRulesContextValue][ANSConfigRulesCheckFuncList];
        
        _userKeysLimit = [_contextInfo[@"additional"][@"userKeysLimit"] integerValue];
        _allKeysCount = [_contextInfo[@"additional"][@"allKeysLimit"] integerValue];
    }
    return self;
}

#pragma mark *** 事件接口 ***

- (NSDictionary *)processAppStart {
    return [self fillTemplate:ANSAppStart action:ANSAppStart sdkProperties:nil userProperties:nil];
}

- (NSDictionary *)processAppEnd {
    return [self fillTemplate:ANSAppEnd action:ANSAppEnd sdkProperties:nil userProperties:nil];
}

- (NSDictionary *)processTrack:(NSString *)track properties:(NSDictionary *)properties {
    //  单独校验track事件
    NSArray *checkList = _dataRules[@"track"][ANSConfigRulesCheckFuncList];
    BOOL xwhatCheckResult = [self checkValue:track withRules:checkList];
    if (!xwhatCheckResult) {
        return nil;
    }
    return [self fillTemplate:ANSTrack action:track sdkProperties:nil userProperties:properties];
}

- (NSDictionary *)processPageProperties:(NSDictionary *)pageProperties SDKProperties:(NSDictionary *)sdkProperties {
    return [self fillTemplate:ANSPageView action:ANSPageView sdkProperties:sdkProperties userProperties:pageProperties];
}

- (NSDictionary *)processAliasSDKProperties:(NSDictionary *)sdkProperties {
    return [self fillTemplate:ANSAlias action:ANSAlias sdkProperties:sdkProperties userProperties:nil];
}

- (NSDictionary *)processProfileSetProperties:(NSDictionary *)properties {
    return [self fillTemplate:ANSProfileSetXXX action:ANSProfileSet sdkProperties:properties userProperties:nil];
}

- (NSDictionary *)processProfileSetOnceProperties:(NSDictionary *)properties SDKProperties:(NSDictionary *)sdkProperties {
    return [self fillTemplate:ANSProfileSetXXX action:ANSProfileSetOnce sdkProperties:sdkProperties userProperties:properties];
}

- (NSDictionary *)processProfileIncrementProperties:(NSDictionary *)properties {
    return [self fillTemplate:ANSProfileSetXXX action:ANSProfileIncrement sdkProperties:nil userProperties:properties];
}

- (NSDictionary *)processProfileAppendProperties:(NSDictionary *)properties {
    return [self fillTemplate:ANSProfileSetXXX action:ANSProfileAppend sdkProperties:nil userProperties:properties];
}

- (NSDictionary *)processProfileUnsetWithSDKProperties:(NSDictionary *)sdkProperties {
    return [self fillTemplate:ANSProfileSetXXX action:ANSProfileUnset sdkProperties:sdkProperties userProperties:nil];
}

- (NSDictionary *)processProfileDelete {
    return [self fillTemplate:ANSProfileSetXXX action:ANSProfileDelete sdkProperties:nil userProperties:nil];
}

- (NSDictionary *)processSDKEvent:(NSString *)track properties:(NSDictionary *)properties {
    return [self fillTemplate:ANSTrack action:track sdkProperties:nil userProperties:properties];
}

- (NSDictionary *)processHeatMap {
    return [self fillTemplate:ANSHeatMap action:ANSHeatMap sdkProperties:nil userProperties:nil];
}

#pragma mark *** 部分数据检查接口 ***

- (BOOL)isValidOfpropertyKey:(NSString *)key {
    return [self isValidOfpropertyKey:key type:ANSPropertyDefault];
}

- (BOOL)isValidOfProperties:(NSDictionary *)properties {
    return [self isValidOfProperties:properties type:ANSPropertyDefault];
}

- (BOOL)isValidOfIncrementProperties:(NSDictionary *)properties {
    return [self isValidOfProperties:properties type:ANSPropertyIncrement];
}

- (BOOL)isValidOfAppendProperties:(NSDictionary *)properties {
    return [self isValidOfProperties:properties type:ANSPropertyAppend];
}

- (BOOL)isValidOfIdentify:(NSString *)Identify {
    return [self isValidOfValue:Identify rules:_dataRules[@"identify"]];
}

- (BOOL)isValidOfAliasId:(NSString *)aliasId {
    return [self isValidOfValue:aliasId rules:_dataRules[@"alias"]];
}

- (BOOL)isValidOfAliasOriginalId:(NSString *)originalId {
    return [self isValidOfValue:originalId rules:_dataRules[@"aliasOriginalId"]];
}

#pragma mark *** 内部方法 ***

/**
 根据事件类型获取对应数据模板，并填充数据、校验
 
 @param templateName 模板名称
 @param action xwhat
 @param sdkProperties SDK附加参数
 @param userProperties 用户传入参数
 */
- (NSDictionary *)fillTemplate:(NSString *)templateName
                        action:(id)action
                 sdkProperties:(NSDictionary *)sdkProperties
                userProperties:(NSDictionary *)userProperties {
    NSDictionary *actionTemplate = _dataTemplate[templateName];
    
    NSMutableDictionary *uploadInfo = [NSMutableDictionary dictionary];
    // 1. 填充并校验数据
    NSArray *outerKeys = actionTemplate[ANSConfigTemplateOuter];
    for (NSString *fieldName in outerKeys) {
        // 查找 是否存在对应模块
        if ([actionTemplate.allKeys containsObject:fieldName]) {
            // 1.2 填充并校验模块数据
            NSMutableDictionary *contextInfo = [NSMutableDictionary dictionary];
            NSArray *contextKeys = actionTemplate[fieldName];
            for (NSString *contextFieldName in contextKeys) {
                NSDictionary *contextRules = _dataRules[fieldName][contextFieldName];
                BOOL result = [self checkField:contextFieldName
                                      useRules:contextRules
                                       inValue:action
                                       outInfo:contextInfo];
                if (!result) {
                    return nil;
                }
                uploadInfo[fieldName] = contextInfo;
            }
        } else {
            //  1.1 填充并校验基础数据
            BOOL result = [self checkField:fieldName
                                  useRules:_dataRules[fieldName]
                                   inValue:action
                                   outInfo:uploadInfo];
            if (!result) {
                return nil;
            }
        }
    }
    
    // 2. 校验用户自定义数据(通用统一规则)
    // 2.1 个数限制
    if (![self isValidOfProperties:userProperties type:ANSPropertyDefault]) {
        return nil;
    }
    
    // 3. 数据合并(目前仅有xcontext结构)
    NSMutableDictionary *contextDic = uploadInfo[ANSConfigContext];
    // 3.1 合并数据
    [contextDic addEntriesFromDictionary:userProperties];
    [contextDic addEntriesFromDictionary:sdkProperties];
    if (![templateName isEqualToString:ANSAlias] && ![templateName isEqualToString:ANSProfileSetXXX]) {
        [contextDic addEntriesFromDictionary:[ANSFileManager sharedManager].globalProperties];
    }
    //  3.2 所有key个数限制
    if (contextDic.allKeys.count > _allKeysCount) {
        NSInteger surplusCount = contextDic.allKeys.count - _allKeysCount;
        NSInteger loop = MIN(surplusCount, userProperties.count);
        if (userProperties.allKeys.count) {
            for (int i = 0; i < loop; i++) {
                [contextDic removeObjectForKey:userProperties.allKeys[i]];
            }
        }
    }
    
    return [uploadInfo copy];
}

/**
 检查当前字段是否满足配置中的规则

 @param fieldName 字段名称
 @param ruleDic 字段规则
 @param value 字段传入值
 @param dataInfo 回传引用数据
 @return 是否合法
 */
- (BOOL)checkField:(NSString *)fieldName
          useRules:(NSDictionary *)ruleDic
           inValue:(id)value
           outInfo:(NSMutableDictionary *)dataInfo {
    // 1. 填充数据
    NSInteger getType = [ruleDic[ANSConfigRulesValueType] integerValue];
    id dataValue ;
    switch (getType) {
        case 0: {
            //  通过方法获取数据
            NSString *funcStr = ruleDic[ANSConfigRulesValue];
            NSArray *array = [funcStr componentsSeparatedByString:@"."];
            if (array.count == 2) {
                Class cls = NSClassFromString(array[0]);
                NSString *funcStr = array[1];
                if (cls) {
                    id sharedInstance = [ANSMediator performTarget:cls action:@"sharedManager"];
                    dataValue = [ANSMediator performTarget:sharedInstance action:funcStr];
                }
            }
        }
            break;
        case 1: {
            //  使用配置默认值
            dataValue = ruleDic[ANSConfigRulesValue];
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
    dataInfo[fieldName] = dataValue;
    
    // 2. 规则数据校验
    NSArray *checkFuncList = ruleDic[ANSConfigRulesCheckFuncList];
    if (![self checkValue:dataValue withRules:checkFuncList]) {
        return NO;
    }
    
    return YES;
}


/**
 对context数据的key和value进行校验

 @param properties 自定义信息
 @return 是否符合规则
 */
- (BOOL)isValidOfProperties:(NSDictionary *)properties type:(ANSPropertyType)type; {
    if (properties.allKeys.count > _userKeysLimit) {
        return NO;
    }
    for (id key in properties) {
        if (![self isValidOfpropertyKey:key type:type]) {
            return NO;
        }
        if (![self isValidOfProperyValue:properties[key] type:type]) {
            return NO;
        }
    }
    return YES;
}

/**
 根据配置规则校验context-key是否合法

 @param key context-key
 @param type 类型
 @return 是否合法
 */
- (BOOL)isValidOfpropertyKey:(id)key type:(ANSPropertyType)type {
    return [self checkValue:key withRules:_defaultContextKeyRules];
}

/**
 根据配置规则校验是否合法(可配置特殊校验规则)

 @param value value值
 @param type 类型
 @return 是否合法
 */
- (BOOL)isValidOfProperyValue:(id)value type:(ANSPropertyType)type {
    switch (type) {
        case ANSPropertyDefault:
        {
            return [self checkValue:value withRules:_defaultContextValueRules];
        }
        case ANSPropertyIncrement:
        {
            NSArray *incrementRules = _contextInfo[@"profile_increment"][ANSConfigRulesCheckFuncList];
            return [self checkValue:value withRules:incrementRules];
        }
            break;
        case ANSPropertyAppend:
        {
            NSArray *appendRules = _contextInfo[@"profile_append"][ANSConfigRulesCheckFuncList];
            return [self checkValue:value withRules:appendRules];
        }
            break;
        default:
            break;
    }
    return NO;
}

/** 特殊规则检查 */
- (BOOL)isValidOfValue:(id)value rules:(NSDictionary *)configMap {
    NSArray *rules = configMap[ANSConfigRulesCheckFuncList];
    if (rules) {
        return [self checkValue:value withRules:rules];
    }
    return YES;
}

/**
 根据value执行校验

 @param funcList 方法列表字符串  ANSDataCheck.isValidOfIncrementValue
 @param value 被校验值
 @return 是否合法
 */
- (BOOL)checkValue:(id)value withRules:(NSArray *)funcList {
    for (NSString *func in funcList) {
        NSArray *array = [func componentsSeparatedByString:@"."];
        if (array.count == 2) {
            Class cls = NSClassFromString(array[0]);
            NSString *funcStr = array[1];
            if (cls) {
                id sharedInstance = [ANSMediator performTarget:cls action:@"sharedManager"];
                if (!value) {
                    return NO;
                }
                id result = [ANSMediator performTarget:sharedInstance action:funcStr params:@[value]];
                if (![result boolValue]) {
                    return NO;
                }
            }
        }
    }
    return YES;
}



@end
