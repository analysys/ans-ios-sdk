//
//  ANSAESAlgorithm.h
//  AnalysysAgent
//
//  Created by sysylana on 15/11/24.
//  Copyright © 2015年 sysylana. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class
 * ANSAESAlgorithm
 *
 * @abstract
 * 加解密
 *
 * @discussion
 * AES加密、解密功能
 */

@interface ANSAESAlgorithm : NSObject

/**
 AES ECB模式加密

 @param string 字符串
 @param key 秘钥
 @param keyLength 加密长度
 @return 加密后字符串
 */
+ (NSString *)AESECBEncryptString:(NSString *)string key:(NSString *)key keyLength:(size_t)keyLength;

/**
 AES CBC模式加密

 @param string 字符串
 @param key 秘钥
 @param keyLength 加密长度
 @return 加密后字符串
 */
+ (NSString *)AESCBCEncryptString:(NSString *)string key:(NSString *)key keyLength:(size_t)keyLength;



@end
