//
//  AnalysysJson.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/20.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "AnalysysJson.h"

@implementation AnalysysJson

+ (NSString *)convertToStringWithObject:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        if ([object isEqualToString:@""]) {
            return @"";
        }
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return @"";
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
