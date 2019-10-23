//
//  ANSPassThroughValueTransformer.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSValueTransformers.h"

@implementation ANSPassThroughValueTransformer

+ (Class)transformedValueClass
{
    return [NSObject class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if ([[NSNull null] isEqual:value]) {
        return nil;
    }
    
    if (value == nil) {
        return [NSNull null];
    }
    
    return value;
}

@end
