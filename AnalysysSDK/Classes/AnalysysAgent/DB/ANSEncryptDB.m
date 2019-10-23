//
//  ANSEncryptDB.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/5/28.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSEncryptDB.h"

@implementation ANSEncryptDB

+ (NSString *)base64EncodeWithString:(NSString *)str {
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    NSString *reservedStr = [self stringByReversing:base64Str];
    NSInteger length = reservedStr.length/10;
    NSString *oneToTenStr = [reservedStr substringToIndex:length];
    NSString *nineToTenStr = [reservedStr substringFromIndex:length];
    NSString *retStr = [NSString stringWithFormat:@"%@%@", nineToTenStr, oneToTenStr];
    return retStr;
}

+ (NSString *)base64DecodeWithString:(NSString *)base64Str {
    NSInteger length = base64Str.length/10;
    NSString *oneToTenStr = [base64Str substringFromIndex:(base64Str.length - length)];
    NSString *nineToTenStr = [base64Str substringToIndex:(base64Str.length - length)];
    NSString *originalBase64String = [NSString stringWithFormat:@"%@%@",oneToTenStr, nineToTenStr];
    NSString *reservedStr = [self stringByReversing:originalBase64String];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:reservedStr options:0];
    NSString *tempReturnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return tempReturnString;
}

+ (NSString *)stringByReversing:(NSString *)str {
    NSMutableString *reversed = [NSMutableString stringWithCapacity:str.length];
    NSRange range = NSMakeRange(0, str.length);
    [str enumerateSubstringsInRange:range
                            options:NSStringEnumerationByComposedCharacterSequences
                         usingBlock:^(NSString * _Nullable substring, NSRange substringRange,
                                      NSRange enclosingRange, BOOL * _Nonnull stop) {
                             [reversed insertString:substring atIndex:0];
                         }];
    return reversed;
}

@end
