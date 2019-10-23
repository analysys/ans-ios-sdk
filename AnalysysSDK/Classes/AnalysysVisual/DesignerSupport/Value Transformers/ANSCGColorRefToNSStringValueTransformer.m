//
//  ANSCGColorRefToNSStringValueTransformer.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSValueTransformers.h"

@implementation ANSCGColorRefToNSStringValueTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

- (id)transformedValue:(id)value
{
    if (value && CFGetTypeID((__bridge CFTypeRef)value) == CGColorGetTypeID()) {
        NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:@"ANSUIColorToNSStringValueTransformer"];
        return [transformer transformedValue:[[UIColor alloc] initWithCGColor:(__bridge CGColorRef)value]];
    }
    
    return nil;
}

- (id)reverseTransformedValue:(id)value
{
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:@"ANSUIColorToNSStringValueTransformer"];
    UIColor *uiColor =  [transformer reverseTransformedValue:value];
    return CFBridgingRelease(CGColorCreateCopy([uiColor CGColor]));
}

@end
