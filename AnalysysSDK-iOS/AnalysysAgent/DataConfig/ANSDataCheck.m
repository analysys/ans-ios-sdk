//
//  ANSDataCheck.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSDataCheck.h"
#import "ANSDataProcessing.h"
#import "ANSConsleLog.h"

@implementation ANSDataCheck {
    NSPredicate *_charPredicate; // 字符类型校验
    NSArray *_rulesReservedKeywords; // 保留字段数组
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
        _rulesReservedKeywords = [ANSDataProcessing sharedManager].dataRules[ANSConfigRulesReservedKeyword];
        
        NSString *regular = @"^[$a-zA-Z][a-zA-Z0-9_$]*$";
        _charPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    }
    return self;
}

/** appkey是否合法 */
- (BOOL)isValidOfAppKey:(NSString *)appKey {
    if (appKey.length == 0) {
        [ANSConsleLog logWarningDetail:@"'appKey' can not be empty"];
        return NO;
    }
    return YES;
}

- (BOOL)isValidOfXwho:(NSString *)xwho {
    if (xwho.length == 0) {
        [ANSConsleLog logWarningDetail:@"'xwho' can not be empty"];
        return NO;
    }
    return YES;
}

/** 是否为保留字段 */
- (BOOL)isReservedKey:(NSString *)word {
    if ([_rulesReservedKeywords containsObject:word]) {
        [ANSConsleLog logWarningDetail:[NSString stringWithFormat:@"'%@' is reserved key", word]];
        return NO;
    }
    return YES;
}

/** xwho字符串长度校验 */
- (BOOL)isValidLengthOfXwho:(NSString *)xwho {
    if (xwho.length == 0 || xwho.length > 99) {
        [ANSConsleLog logWarningDetail:@"The length of string must need to be 1-99"];
        return NO;
    }
    return YES;
}

/** xcontext-key是否为字符串类型 */
- (BOOL)isStringOfContextKey:(id)contextKey {
    if (![contextKey isKindOfClass:NSString.class]) {
        [ANSConsleLog logWarningDetail:[NSString stringWithFormat:@"Property's key type must be NSString, not %@", [contextKey class]]];
        return NO;
    }
    return YES;
}

/** xcontext->key长度校验 */
- (BOOL)isValidLengthOfContextKey:(NSString *)contextKey {
    if (contextKey.length == 0 || contextKey.length > 125) {
        [ANSConsleLog logWarning:nil value:contextKey detail:@"The length of string must need to be 1-125"];
        return NO;
    }
    return YES;
}

/** xwho 字符串类型检查 */
- (BOOL)isValidOfXwhoChars:(NSString *)xwho {
    if (![_charPredicate evaluateWithObject:xwho]) {
        [ANSConsleLog logWarning:nil value:xwho detail:@"The string need to begin with [a-zA-Z] and only contain [a-zA-Z0-9_]"];
        return NO;
    }
    return YES;
}

/** 匿名id合法性检查 */
- (BOOL)isValidOfIdentify:(NSString *)anonymousId {
    if (anonymousId.length == 0 || anonymousId.length > 255) {
        [ANSConsleLog logWarning:nil value:anonymousId detail:@"The length of string must need to be 1-255"];
        return NO;
    }
    return YES;
}

/** aliasId是否合法 */
- (BOOL)isValidOfAliasId:(NSString *)aliasId {
    if (aliasId.length == 0 || aliasId.length > 255) {
        [ANSConsleLog logWarning:nil value:aliasId detail:@"The length of string must need to be 1-255"];
        return NO;
    }
    return YES;
}

/** originalId是否合法 */
- (BOOL)isValidOfAliasOriginalId:(NSString *)originalId {
    if (originalId.length > 255) {
        [ANSConsleLog logWarning:nil value:originalId detail:@"The length of string must need to be 0-255"];
        return NO;
    }
    return YES;
}

/** 检查context->value类型是否合法 */
- (BOOL)isValidTypeOfContextValue:(id)value {
    if([value isKindOfClass:[NSString class]] ||
       [value isKindOfClass:[NSNumber class]] ||
       [value isKindOfClass:[NSArray class]] ||
       [value isKindOfClass:[NSSet class]] ||
       [value isKindOfClass:[NSDate class]] ||
       [value isKindOfClass:[NSURL class]]) {
        return YES;
    }
    NSString *detail = [NSString stringWithFormat:@"Property value invalid, support type: NSString/NSNumber/BOOL/NSArray<NSString>/NSSet<NSString>/NSDate/NSURL \ncurrent value: %@ \ncurrent type: %@", value, [value class]];
    [ANSConsleLog logWarning:nil value:value detail:detail];
    return NO;
}

/** 检查 默认context->value值是否合法 */
- (BOOL)isValidOfContextValue:(id)value {
    return [self validPropertyValue:value depth:0];
}

- (BOOL)validPropertyValue:(id)value depth:(NSUInteger)depth {
    if ([value isKindOfClass:[NSArray class]]) {
        return [self validPropertyTypesInArray:value depth:depth+1];
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSArray *array = [value allObjects];
        return [self validPropertyTypesInArray:array depth:depth+1];
    } else if ([value isKindOfClass:[NSString class]]) {
        NSString *pvalue = (NSString *)value;
        if (pvalue.length == 0 || pvalue.length > 255) {
            [ANSConsleLog logWarning:nil value:pvalue detail:@"The length of the property value needs to be 1-255"];
            return NO;
        }
    } else if (depth > 0 && ![value isKindOfClass:NSString.class]) {
        [ANSConsleLog logWarningDetail:@"The property value array must be NSArray<NSString *>"];
        return NO;
    }
    return YES;
}

- (BOOL)validPropertyTypesInArray:(NSArray *)propertyArray depth:(NSUInteger)depth {
    if(propertyArray.count == 0 || propertyArray.count > 100) {
        [ANSConsleLog logWarningDetail:@"The length of the property value array needs to be 1-100"];
        return NO;
    }
    for (id value in propertyArray) {
        if (![self validPropertyValue:value depth:depth]) {
            return NO;
            break;
        }
    }
    return YES;
}

/** 检查profile_increment->value是否合法 */
- (BOOL)isValidOfIncrementValue:(id)value {
    if (![value isKindOfClass:[NSNumber class]]) {
        [ANSConsleLog logWarningDetail:@"property.value must be NSNumber"];
        return NO;
    }
    return YES;
}

/** 检查profile_append->value是否合法 */
- (BOOL)isValidOfAppendValue:(id)value {
    if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSSet class]]) {
        return YES;
    }
    [ANSConsleLog logWarningDetail:@"property.value must be NSArray/NSSet"];
    return NO;
}

@end
