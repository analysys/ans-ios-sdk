//
//  NSString+ANSDBEncrypt.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/10/24.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "NSString+ANSDBEncrypt.h"


@implementation NSString (ANSDBEncrypt)

- (NSString *)ansBase64Encode {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    NSString *reversedStr = [base64Str reversing];
    NSInteger length = reversedStr.length/10;
    NSString *oneToTenStr = [reversedStr substringToIndex:length];
    NSString *nineToTenStr = [reversedStr substringFromIndex:length];
    NSString *encodeString = [NSString stringWithFormat:@"%@%@", nineToTenStr, oneToTenStr];
    return [encodeString copy];
}

- (NSString *)ansBase64Decode {
    NSInteger length = self.length/10;
    NSString *oneToTenStr = [self substringFromIndex:(self.length - length)];
    NSString *nineToTenStr = [self substringToIndex:(self.length - length)];
    NSString *originalBase64String = [NSString stringWithFormat:@"%@%@",oneToTenStr, nineToTenStr];
    NSString *reservedStr = [originalBase64String reversing];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:reservedStr options:0];
    NSString *decodeString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return decodeString;
}

- (NSString *)reversing {
    NSMutableString *reversed = [NSMutableString stringWithCapacity:self.length];
    NSRange range = NSMakeRange(0, self.length);
    [self enumerateSubstringsInRange:range
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString * _Nullable substring, NSRange substringRange,
                                       NSRange enclosingRange, BOOL * _Nonnull stop) {
        [reversed insertString:substring atIndex:0];
    }];
    return reversed;
}

@end
