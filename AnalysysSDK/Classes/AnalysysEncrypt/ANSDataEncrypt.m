//
//  ANSDataEncrypt.m
//  AnalysysAgent
//
//  Created by SoDo on 2018/9/10.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "ANSDataEncrypt.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "ANSAESAlgorithm.h"
#import "ANSConst+private.h"
#import "AnalysysAgentConfig.h"

@implementation ANSDataEncrypt

#pragma mark - interface

+ (NSDictionary *)extroHeaderInfo {
    NSMutableDictionary *header = [NSMutableDictionary dictionary];
    switch (AnalysysConfig.encryptType) {
        case AnalysysEncryptAES:
        {
            NSString *curTime = [NSString stringWithFormat:@"%lld",[self currentTimeMillisecond]];
            [header setValue:@"1" forKey:@"reqv"];
            [header setValue:curTime forKey:@"reqt"];
        }
            break;
        case AnalysysEncryptAESCBC128:
        {
            NSString *curTime = [NSString stringWithFormat:@"%lld",[self currentTimeMillisecond]];
            [header setValue:@"2" forKey:@"reqv"];
            [header setValue:curTime forKey:@"reqt"];
        }
            break;
        default:
            break;
    }
    
    return header;
}

+ (NSString *)encryptJsonString:(NSString *)jsonString param:(NSDictionary *)param {
    NSString *encryptStr = jsonString;
    switch (AnalysysConfig.encryptType) {
        case AnalysysEncryptAES:
        {
            NSString *baseStr = [NSString stringWithFormat:@"iOS%@%@%@",AnalysysConfig.appKey,  ANSSDKVersion, param[@"reqt"]];
            NSString *encryptKey = [self getEncrptKeyWithString:baseStr];
            encryptStr = [ANSAESAlgorithm AESECBEncryptString:jsonString key:encryptKey keyLength:kCCKeySizeAES128];
        }
            break;
        case AnalysysEncryptAESCBC128:
        {
            NSString *baseStr = [NSString stringWithFormat:@"iOS%@%@%@",AnalysysConfig.appKey, ANSSDKVersion, param[@"reqt"]];
            NSString *encryptKey = [self getEncrptKeyWithString:baseStr];
            encryptStr = [ANSAESAlgorithm AESCBCEncryptString:jsonString key:encryptKey keyLength:kCCKeySizeAES128];
        }
            break;
        default:
            break;
    }
    return encryptStr;
}

#pragma mark - inner

/** 计算加密key */
+ (NSString *)getEncrptKeyWithString:(NSString *)encryptionBaseStr {
    NSString *md5Str = [self MD5ToUpper32Bit:encryptionBaseStr];
    
    NSData *data = [md5Str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    
    NSArray *versionArray = [ANSSDKVersion componentsSeparatedByString:@"."];
    //  末尾决定奇数、偶数位，奇数取奇数位的数值
    //  逆序第二位决定查找顺序，偶数正序，奇数逆序
    NSInteger lastVersion = [versionArray.lastObject integerValue];
    NSInteger lastSecondVersion = [versionArray[versionArray.count-2] integerValue];
    NSString *encryptStr = @"";
    
    if (lastSecondVersion % 2 == 1) {
        base64Str = [self reverseString:base64Str];
    }
    
    if (lastVersion % 2 == 0) { //  偶数
        for (NSInteger i = 1; i < base64Str.length; i += 2) {
            NSRange range = NSMakeRange(i, 1);
            encryptStr = [NSString stringWithFormat:@"%@%@",encryptStr,[base64Str substringWithRange:range]];
        }
    } else { //  奇数
        for (NSInteger i = 0; i < base64Str.length; i += 2) {
            NSRange range = NSMakeRange(i, 1);
            encryptStr = [NSString stringWithFormat:@"%@%@",encryptStr,[base64Str substringWithRange:range]];
        }
    }
    
    if (encryptStr.length < 16) {
        //  key不足16位，翻转补位
        NSInteger shortOfEncrypt = 16 - encryptStr.length;
        NSInteger maxIndex = encryptStr.length - shortOfEncrypt - 1;
        for (NSInteger i = encryptStr.length-1; i > maxIndex; i--) {
            NSRange range = NSMakeRange(i, 1);
            encryptStr = [NSString stringWithFormat:@"%@%@",encryptStr,[encryptStr substringWithRange:range]];
        }
    } else {
        encryptStr = [encryptStr substringToIndex:16];
    }
    
    return encryptStr;
}

/** 字符串翻转 */
+ (NSString *)reverseString:(NSString *)str {
    NSMutableString *targetStr = [NSMutableString string];
    for (NSUInteger i=str.length; i>0; i--) {
        [targetStr appendString:[str substringWithRange:NSMakeRange(i-1, 1)]];
    }
    return targetStr;
}

/** 当前时间戳 */
+ (long long)currentTimeMillisecond {
    NSDate *date = [NSDate date];
    NSTimeInterval nowtime = [date timeIntervalSince1970]*1000;
    long long timeLongValue = [[NSNumber numberWithDouble:nowtime] longLongValue];
    return timeLongValue;
}

/** MD5 */
+ (NSString *)MD5ToUpper32Bit:(NSString *)string {
    const char *input = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02X", result[i]];
    }
    
    return digest;
}


@end
