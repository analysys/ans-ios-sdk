//
//  ANSValueTransformers.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import <UIKit/UIKit.h>

/** 类型转换 */

@interface ANSPassThroughValueTransformer : NSValueTransformer

@end

@interface ANSBOOLToNSNumberValueTransformer : NSValueTransformer

@end

@interface ANSCATransform3DToNSDictionaryValueTransformer : NSValueTransformer

@end

@interface ANSCGAffineTransformToNSDictionaryValueTransformer : NSValueTransformer

@end

@interface ANSCGColorRefToNSStringValueTransformer : NSValueTransformer

@end

@interface ANSCGPointToNSDictionaryValueTransformer : NSValueTransformer

@end

@interface ANSCGRectToNSDictionaryValueTransformer : NSValueTransformer

@end

@interface ANSCGSizeToNSDictionaryValueTransformer : NSValueTransformer

@end

@interface ANSNSAttributedStringToNSDictionaryValueTransformer : NSValueTransformer

@end

@interface ANSUIColorToNSStringValueTransformer : NSValueTransformer

@end

@interface ANSUIEdgeInsetsToNSDictionaryValueTransformer : NSValueTransformer

@end

@interface ANSUIFontToNSDictionaryValueTransformer : NSValueTransformer

@end

@interface ANSUIImageToNSDictionaryValueTransformer : NSValueTransformer

@end

@interface ANSNSNumberToCGFloatValueTransformer : NSValueTransformer

@end

__unused static id transformValue(id value, NSString *toType)
{
    assert(value != nil);
    
    if ([value isKindOfClass:[NSClassFromString(toType) class]]) {
        return [[NSValueTransformer valueTransformerForName:@"ANSPassThroughValueTransformer"] transformedValue:value];
    }
    
    NSString *fromType = nil;
    NSArray *validTypes = @[[NSString class], [NSNumber class], [NSDictionary class], [NSArray class], [NSNull class]];
    for (Class c in validTypes) {
        if ([value isKindOfClass:c]) {
            fromType = NSStringFromClass(c);
            break;
        }
    }
    
    assert(fromType != nil);
    NSValueTransformer *transformer = nil;
    NSString *forwardTransformerName = [NSString stringWithFormat:@"ANS%@To%@ValueTransformer", fromType, toType];
    transformer = [NSValueTransformer valueTransformerForName:forwardTransformerName];
    if (transformer) {
        return [transformer transformedValue:value];
    }
    
    NSString *reverseTransformerName = [NSString stringWithFormat:@"ANS%@To%@ValueTransformer", toType, fromType];
    transformer = [NSValueTransformer valueTransformerForName:reverseTransformerName];
    if (transformer && [[transformer class] allowsReverseTransformation]) {
        return [transformer reverseTransformedValue:value];
    }
    
    return [[NSValueTransformer valueTransformerForName:@"ANSPassThroughValueTransformer"] transformedValue:value];
}
