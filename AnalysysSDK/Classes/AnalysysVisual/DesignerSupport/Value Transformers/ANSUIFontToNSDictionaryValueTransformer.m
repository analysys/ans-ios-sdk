//
//  ANSUIFontToNSDictionaryValueTransformer.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSValueTransformers.h"

@implementation ANSUIFontToNSDictionaryValueTransformer

+ (Class)transformedValueClass {
    return [NSDictionary class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[UIFont class]]) {
        UIFont *fontValue = value;
        
        return @{
                 @"familyName": fontValue.familyName,
                 @"fontName": fontValue.fontName,
                 @"pointSize": @(fontValue.pointSize),
                 };
    }
    
    return nil;
}

- (id)reverseTransformedValue:(id)value {
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionaryValue = value;
        
        NSNumber *pointSize = dictionaryValue[@"pointSize"];
        NSString *fontName = dictionaryValue[@"fontName"];
        
        float fontSize = [pointSize floatValue];
        if (fontSize > 0.0f && fontName) {
            UIFont *systemFont = [UIFont systemFontOfSize:fontSize];
            UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:fontSize];
            UIFont *italicSystemFont = [UIFont italicSystemFontOfSize:fontSize];
            
            if ([systemFont.fontName isEqualToString:fontName]) {
                return systemFont;
            }
            else if ([boldSystemFont.fontName isEqualToString:fontName])
            {
                return boldSystemFont;
            }
            else if ([italicSystemFont.fontName isEqualToString:fontName])
            {
                return italicSystemFont;
            } else {
                return [UIFont fontWithName:fontName size:fontSize];
            }
        }
    }
    
    return nil;
}


@end
