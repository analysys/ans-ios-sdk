//
//  ANSDataCheck.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSDataCheck.h"

#import "ANSDataCheckLog.h"
#import "AnalysysLogger.h"
#import "ANSDataConfig.h"
#import "ANSUtil.h"

static NSPredicate *charPredicate = nil;


@implementation ANSDataCheck

#pragma mark - other

+ (NSPredicate *)charPredicate {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *regular = @"^[$a-zA-Z][a-zA-Z0-9_$]*$";
        charPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    });
    return charPredicate;
}

#pragma mark - check rules

/** appkey校验 */
+ (ANSDataCheckLog *)checkAppKey:(NSString *)appKey {
    ANSDataCheckLog *checkResult = nil;
    if (appKey.length == 0) {
        checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultNotNil;
        checkResult.keyWords = @"appkey";
    }
    return checkResult;
}

/** xwho校验 */
+ (ANSDataCheckLog *)checkXwho:(NSString *)xwho {
    ANSDataCheckLog *checkResult = nil;
    if (xwho.length == 0) {
        checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultNotNil;
        checkResult.keyWords = @"xwho";
    }
    return checkResult;
}

/** 保留字段校验 */
+ (ANSDataCheckLog *)checkReservedKey:(NSString *)word {
    ANSDataCheckLog *checkResult = nil;
    NSArray *reservedKeywords = [ANSDataConfig sharedManager].dataRules[ANSRulesReservedKeyword];
    if ([reservedKeywords containsObject:word]) {
        checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultReservedKey;
        checkResult.value = word;
    }
    return checkResult;
}


/** xwhat字符串长度校验 */
+ (ANSDataCheckLog *)checkLengthOfXwhat:(NSString *)xwhat {
    ANSDataCheckLog *checkResult = nil;
    if (xwhat.length == 0 || xwhat.length > 99) {
        checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultOutOfString;
        checkResult.keyWords = @"1-99";
        checkResult.value = xwhat;
    }
    return checkResult;
}

/** property.key是否为字符串类型 */
+ (ANSDataCheckLog *)checkTypeOfPropertyKey:(id)key {
    ANSDataCheckLog *checkResult = nil;
    if (![key isKindOfClass:NSString.class]) {
        checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultTypeError;
        checkResult.keyWords = @"NSString";
        checkResult.value = key;
    }
    return checkResult;
}

/** property.key长度校验 */
+ (ANSDataCheckLog *)checkLengthOfPropertyKey:(NSString *)key {
    ANSDataCheckLog *checkResult = nil;
    if (key.length == 0 || key.length > 99) {
        checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultOutOfString;
        checkResult.keyWords = @"1-99";
        checkResult.value = key;
    }
    return checkResult;
}

/** xwho 字符串类型检查 */
+ (ANSDataCheckLog *)checkCharsOfXwho:(NSString *)xwho {
    ANSDataCheckLog *checkResult = nil;
    if (![[self charPredicate] evaluateWithObject:xwho]) {
        checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultIllegalOfString;
        checkResult.value = xwho;
    }
    return checkResult;
}

/** 匿名id合法性检查 */
+ (ANSDataCheckLog *)checkLengthOfIdentify:(NSString *)anonymousId {
    ANSDataCheckLog *checkResult = nil;
    if (anonymousId.length == 0 || anonymousId.length > 255) {
        checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultOutOfString;
        checkResult.keyWords = @"1-255";
        checkResult.value = anonymousId;
    }
    return checkResult;
}

/** aliasId是否合法 */
+ (ANSDataCheckLog*)checkLengthOfAliasId:(NSString *)aliasId {
    ANSDataCheckLog *checkResult = nil;
    if (aliasId.length == 0 || aliasId.length > 255) {
        checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultOutOfString;
        checkResult.keyWords = @"1-255";
        checkResult.value = aliasId;
    }
    return checkResult;
}

/** originalId检查 */
+ (ANSDataCheckLog *)checkAliasOriginalId:(NSString *)originalId {
    if (originalId.length == 0 || originalId == nil) {
        return nil;
    }
    ANSDataCheckLog *checkResult = nil;
    if (originalId.length > 255) {
        checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultOutOfString;
        checkResult.keyWords = @"0-255";
        checkResult.value = originalId;
    }
    return checkResult;
}

/** 检查 自定义属性value值 */
+(ANSDataCheckLog *)checkPropertyValueWithKey:(NSString *)key value:(id)value {
    ANSDataCheckLog *checkResult = nil;
    id newValue;
    BOOL valueDidChange = NO;
    NSMutableSet *newSetObject = [NSMutableSet set];
    
    if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSSet class]]) {
        if ([value count] == 0) {
            valueDidChange = YES;
            
            checkResult = [[ANSDataCheckLog alloc]init];
            checkResult.resultType = AnalysysResultPropertyValueFixed;
            checkResult.value = value;
            checkResult.valueFixed = nil;
        }
        id object = nil;
        NSEnumerator *enumerator = [value objectEnumerator];
        while (object = [enumerator nextObject]) {
            if ([object isKindOfClass:[NSString class]]) {
                NSString *valueString = (NSString *)object;
                NSUInteger objLength = [valueString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
                // 超长字符串截取
                if (objLength > ANSPropertyValueMaxLength) {
                    // 截取后末尾拼接$，替换原数据
                    NSMutableString *newObject = [NSMutableString stringWithString:[ANSUtil subByteString:valueString byteLength:ANSPropertyValueMaxLength - 1]];
                    [newObject appendString:@"$"];
                    [newSetObject addObject:newObject.copy];
                    ANSBriefWarning(@"The length of property[%@] value string in NSArray/NSSet (%@) needs to be 1-255!", key, object);
                    valueDidChange = YES;
                } else {
                    if (objLength > ANSPropertyValueWarningLength) {
                        ANSBriefWarning(@"The length of property[%@] value string in NSArray/NSSet (%@) needs to be 1-255!", key, object);
                    }
                    if (objLength > 0) {
                        [newSetObject addObject:valueString];
                    } else {
                        ANSBriefWarning(@"The length of property[%@] value string in NSArray/NSSet needs to be 1-255!", key);
                    }
                }
            } else if ([object isKindOfClass:[NSNull class]]) {
                [newSetObject addObject:@""];
                valueDidChange = YES;
                
                checkResult = [[ANSDataCheckLog alloc] init];
                checkResult.resultType = AnalysysResultPropertyValueFixed;
                checkResult.value = value;
                checkResult.valueFixed = nil;
            } else {
                [newSetObject addObject:object];
                
                checkResult = [[ANSDataCheckLog alloc] init];
                checkResult.resultType = AnalysysResultTypeError;
                checkResult.keyWords = @"NSArray<NSString *>,NSSet<NSString *>";
                checkResult.value = value;
                break;
            }
        }
        // 检查集合元素个数，并将多余元素删除
        NSInteger count = newSetObject.count;
        if (count > ANSPropertySetCapacity) {
            ANSBriefWarning(@"The length of property[%@] value count '%@' needs to be 1-100!", key, value);
        }
        newValue = [newSetObject.allObjects copy];
    } else if ([value isKindOfClass:[NSString class]]) {
        NSString *pvalue = (NSString *)value;
        NSUInteger valueLength = [pvalue lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        if (valueLength > ANSPropertyValueMaxLength) {
            NSMutableString *newObject = [NSMutableString stringWithString:[ANSUtil subByteString:pvalue byteLength:ANSPropertyValueMaxLength - 1]];
            [newObject appendString:@"$"];
            newValue = [newObject copy];
            valueDidChange = YES;
            ANSBriefWarning(@"The length of property[%@] value (%@) needs to be 1-255!", key, pvalue);
        } else {
            if (valueLength > ANSPropertyValueWarningLength) {
                ANSBriefWarning(@"The length of property[%@] value (%@) needs to be 1-255!", key, pvalue);
            }
            if (valueLength == 0) {
                ANSBriefWarning(@"The length of property[%@] value string needs to be 1-255!", key);
            }
            newValue = pvalue;
        }
    }
    
    if (valueDidChange) {
        checkResult = [[ANSDataCheckLog alloc]init];
        checkResult.resultType = AnalysysResultPropertyValueFixed;
        checkResult.value = value;
        checkResult.valueFixed = newValue;
    }
    return checkResult;
}


/** property.value类型检查 */
+ (ANSDataCheckLog *)checkTypeOfPropertyValueWithKey:(NSString *)key  value:(id )value {
    if([value isKindOfClass:[NSString class]] ||
       [value isKindOfClass:[NSNumber class]] ||
       [value isKindOfClass:[NSArray class]] ||
       [value isKindOfClass:[NSSet class]] ||
       [value isKindOfClass:[NSDate class]] ||
       [value isKindOfClass:[NSURL class]]) {
        return nil;
    }
    ANSDataCheckLog *checkResult = nil;
    checkResult = [[ANSDataCheckLog alloc] init];
    checkResult.resultType = AnalysysResultTypeError;
    checkResult.keyWords = @"NSString/NSNumber/NSArray<NSString>/NSSet<NSString>/NSDate/NSURL";
    checkResult.value = value;
    return checkResult;
}

/** 检查profile_increment.value */
+ (ANSDataCheckLog *)checkTypeOfIncrementPropertyValueWithKey:(NSString *)key value:(id)value {
    ANSDataCheckLog *checkResult = nil;
    if (![value isKindOfClass:[NSNumber class]]) {
        checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultTypeError;
        checkResult.keyWords = @"NSNumber";
        checkResult.value = value;
    }
    return checkResult;
}

/** 检查profile_append.value */
+ (ANSDataCheckLog *)checkTypeOfAppendPropertyValueWithKey:(NSString *)key value:(id)value {
    ANSDataCheckLog *checkResult = nil;
    if ([value isKindOfClass:NSString.class]) {
        value = [NSArray arrayWithObject:value];
    }
    
    if (![value isKindOfClass:[NSArray class]] &&
        ![value isKindOfClass:[NSSet class]]) {
        checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultTypeError;
        checkResult.keyWords = @"NSArray/NSSet";
        checkResult.value = value;
    }
    return checkResult;
}

@end
