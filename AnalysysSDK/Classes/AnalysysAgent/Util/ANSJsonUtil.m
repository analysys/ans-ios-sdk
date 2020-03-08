//
//  ANSJsonUtil.m
//  AnalysysAgent
//
//  Created by analysys on 2018/2/6.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "ANSJsonUtil.h"
#import "AnalysysLogger.h"
#import "ANSDateUtil.h"

@implementation ANSJsonUtil

+ (NSData *)jsonSerializeWithObject:(id)obj {
    NSData *data = nil;
    @try {
        id coercedObj = [ANSJsonUtil convertToJsonObjectWithObject:obj];
        //        if (@available(iOS 11.0, *)) {
        //            data = [NSJSONSerialization dataWithJSONObject:coercedObj options:NSJSONWritingSortedKeys error:&error];
        //        } else {
        //            data = [NSJSONSerialization dataWithJSONObject:coercedObj options:NSJSONWritingPrettyPrinted error:&error];
        //        }
        data = [NSJSONSerialization dataWithJSONObject:coercedObj options:0 error:nil];
    } @catch (NSException *exception) {
        ANSDebug(@"JSON serialized exception:%@", exception);
    }
    return [data copy];
}

+ (id)convertToJsonObjectWithObject:(id)obj {
    if ([obj isKindOfClass:[NSString class]] ||
        [obj isKindOfClass:[NSNumber class]] ) {
        return obj;
    }

    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *a = [NSMutableArray array];
        for (id i in obj) {
            [a addObject:[ANSJsonUtil convertToJsonObjectWithObject:i]];
        }
        return [NSArray arrayWithArray:a];
    }
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        for (id key in obj) {
            NSString *stringKey;
            if (![key isKindOfClass:[NSString class]]) {
                stringKey = [key description];
                ANSBriefError(@"Property keys should be string. got: %@. coercing to: %@", [key class], stringKey);
            } else {
                stringKey = [NSString stringWithString:key];
            }
            id v = [ANSJsonUtil convertToJsonObjectWithObject:obj[key]];
            [d setValue:v forKey:stringKey];
        }
        return [NSDictionary dictionaryWithDictionary:d];
    }
    
    if ([obj isKindOfClass:[NSSet class]]) {
        NSMutableArray *a = [NSMutableArray array];
        for (id i in obj) {
            [a addObject:[ANSJsonUtil convertToJsonObjectWithObject:i]];
        }
        return [NSArray arrayWithArray:a];
    }

    if ([obj isKindOfClass:[NSDate class]]) {
        return [[ANSDateUtil dateFormat] stringFromDate:obj];
    }
    
    if ([obj isKindOfClass:[NSURL class]]) {
        return [NSString stringWithFormat:@"%@", obj];
    }

    NSString *des = [obj description];
    ANSBriefError(@"Property values should be valid json types. got: %@. coercing to: %@", [obj class], des);
    return [des copy];
}

+ (NSDictionary *)convertToMapWithString:(NSString *)jsonStr {
    NSError *error = nil;
    NSData *getJsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    if (!getJsonData) {
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:getJsonData options:NSJSONReadingMutableContainers error:&error];
    if (error == nil && [dict isKindOfClass:[NSDictionary class]]) {
        return dict;
    }
    return nil;
}

+ (NSString *)convertToStringWithObject:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        if ([object isEqualToString:@""]) {
            return @"";
        }
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:(NSJSONWritingOptions)0 error:&error];
    if (error) {
        return @"";
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
