//
//  ANSBOOLToNSNumberValueTransformer.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSValueTransformers.h"

@implementation ANSBOOLToNSNumberValueTransformer

+ (Class)transformedValueClass {
    return [@YES class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if ([value respondsToSelector:@selector(boolValue)]) {
        return @([value boolValue]);
    }
    
    return nil;
}

@end
