//
//  NSString+ANSMD5.m
//  AnalysysAgent
//
//  Created by SoDo on 2018/11/29.
//  Copyright © 2018 analysys. All rights reserved.
//

#import "NSString+ANSMD5.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (ANSMD5)

/** MD5 32位 */
- (NSString *)AnsMD5ToUpper32Bit {
    const char *input = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02X", result[i]];
    }
    
    return digest;
}

- (NSString *)AnsMD5ToUpper16Bit {
    NSString *md5Str = [self AnsMD5ToUpper32Bit];
    NSString *string = @"";
    if (md5Str.length > 24) {
        string = [md5Str substringWithRange:NSMakeRange(8, 16)];
    }
    return string;
}


@end
