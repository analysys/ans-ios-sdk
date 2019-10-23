//
//  ANSAESAlgorithm.m
//
//  Created by sysylana on 15/11/24.
//  Copyright © 2015年 sysylana. All rights reserved.
//

#import "ANSAESAlgorithm.h"
#import <CommonCrypto/CommonCryptor.h>

static NSString *const ANSAES218IV = @"Analysys_315$CBC";

@implementation ANSAESAlgorithm

#pragma mark - interface

+ (NSString *)AESECBEncryptString:(NSString *)string key:(NSString *)key keyLength:(size_t)keyLength {
    NSData *sourceData = [string dataUsingEncoding:NSUTF8StringEncoding];
    char keyPtr[keyLength+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [sourceData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode  ,
                                          keyPtr, keyLength,
                                          NULL,
                                          [sourceData bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *tempData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        NSString *tempStr = [ANSAESAlgorithm hexStringFromData:tempData];
        return tempStr;
    }
    free(buffer);
    return @"";
}

+ (NSString *)AESCBCEncryptString:(NSString *)string key:(NSString *)key keyLength:(size_t)keyLength {
    char keyPtr[keyLength + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    // IV
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    [ANSAES218IV getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                            keyPtr, keyLength,
                                            ivPtr,
                                            [data bytes], [data length],
                                            buffer, bufferSize,
                                            &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *tempData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        NSString *tempStr = [ANSAESAlgorithm hexStringFromData:tempData];
        return tempStr;
    }
    free(buffer);
    return @"";
}

+ (NSString *)DecryptAESECB128String:(NSString *)encryptString withKey:(NSString *)key {
    if (key.length > kCCKeySizeAES128) {
        key = [key substringToIndex:kCCKeySizeAES128];
    } else if(key.length < kCCKeySizeAES128){
        NSInteger offset = kCCKeySizeAES128 - key.length;
        for (int i = 0; i < offset; i++) {
            key = [NSString stringWithFormat:@"%@%@", key, @"0"];
        }
    }

    NSData *sourceData = [ANSAESAlgorithm dataFromHexString:encryptString];

    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [sourceData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL,
                                          [sourceData bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *tempData = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        NSString *tempStr = [[NSString alloc]initWithData:tempData encoding:NSUTF8StringEncoding];
        return tempStr;

    }
    free(buffer);
    return @"";
}

#pragma mark - inner

/** NSData 转 16进制字符串 */
+ (NSString *)hexStringFromData:(NSData *)data {
    static const char hexdigits[] = "0123456789ABCDEF";
    const size_t numBytes = [data length];
    const unsigned char* bytes = [data bytes];
    char *strbuf = (char *)malloc(numBytes * 2 + 1);
    char *hex = strbuf;
    NSString *hexBytes = nil;

    for (int i = 0; i<numBytes; ++i) {
        const unsigned char c = *bytes++;
        *hex++ = hexdigits[(c >> 4) & 0xF];
        *hex++ = hexdigits[(c ) & 0xF];
    }
    *hex = 0;
    hexBytes = [NSString stringWithUTF8String:strbuf];
    free(strbuf);

    return hexBytes;
}

/** 16进制字符串 转 NSData 对象 */
+ (NSData *)dataFromHexString:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }

    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];

        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];

        range.location += range.length;
        range.length = 2;
    }

    return hexData;
}




@end
