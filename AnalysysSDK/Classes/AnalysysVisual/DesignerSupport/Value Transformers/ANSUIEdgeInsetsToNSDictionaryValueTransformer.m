//
//  ANSUIEdgeInsetsToNSDictionaryValueTransformer.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSValueTransformers.h"

@implementation ANSUIEdgeInsetsToNSDictionaryValueTransformer

+ (Class)transformedValueClass {
    return [NSDictionary class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    if ([value respondsToSelector:@selector(UIEdgeInsetsValue)]) {
        UIEdgeInsets edgeInsetsValue = [value UIEdgeInsetsValue];
        
        return @{
                 @"top"    : @(edgeInsetsValue.top),
                 @"bottom" : @(edgeInsetsValue.bottom),
                 @"left"   : @(edgeInsetsValue.left),
                 @"right"  : @(edgeInsetsValue.right)
                 };
    }
    
    return nil;
}

- (id)reverseTransformedValue:(id)value {
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionaryValue = value;
        
        id top = dictionaryValue[@"top"];
        id bottom = dictionaryValue[@"bottom"];
        id left = dictionaryValue[@"left"];
        id right = dictionaryValue[@"right"];
        
        if (top && bottom && left && right) {
            UIEdgeInsets edgeInsets = UIEdgeInsetsMake([top floatValue], [left floatValue], [bottom floatValue], [right floatValue]);
            return [NSValue valueWithUIEdgeInsets:edgeInsets];
        }
    }
    
    return [NSValue valueWithUIEdgeInsets:UIEdgeInsetsZero];
}


@end
