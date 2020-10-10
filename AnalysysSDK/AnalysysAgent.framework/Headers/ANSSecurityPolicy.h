//
//  ANSSecurityPolicy.h
//  AnalysysAgent
//
//  Created by SoDo on 2020/8/6.
//  Copyright © 2020 shaochong du. All rights reserved.
//

// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ANSSSLPinningMode) {
    ANSSSLPinningModeNone,  //  不验证证书
    ANSSSLPinningModePublicKey, //  只验证公钥
    ANSSSLPinningModeCertificate    //  验证证书
};

NS_ASSUME_NONNULL_BEGIN

@interface ANSSecurityPolicy : NSObject <NSSecureCoding, NSCopying>

/// 证书验证模式，默认：ANSSSLPinningModeNone
@property (readonly, nonatomic, assign) ANSSSLPinningMode SSLPinningMode;

/// 证书内容
@property (nonatomic, strong, nullable) NSSet <NSData *> *pinnedCertificates;

/// 是否信任不合法（无效或过期）证书，默认：NO
@property (nonatomic, assign) BOOL allowInvalidCertificates;

/// 是否验证域名
@property (nonatomic, assign) BOOL validatesDomainName;


/// 获取默认验证对象
+ (instancetype)defaultPolicy;

/// 读取本地bundle证书
/// @param bundle bundle
+ (NSSet <NSData *> *)certificatesInBundle:(NSBundle *)bundle;

/// 设置 ANSSSLPinningMode 获取验证对象
/// @param pinningMode ANSSSLPinningMode枚举
+ (instancetype)policyWithPinningMode:(ANSSSLPinningMode)pinningMode;

/// 设置 ANSSSLPinningMode 和 证书内容，获取验证对象
/// @param pinningMode ANSSSLPinningMode
/// @param pinnedCertificates 证书内容
+ (instancetype)policyWithPinningMode:(ANSSSLPinningMode)pinningMode withPinnedCertificates:(NSSet <NSData *> *)pinnedCertificates;

/// 证书验证
/// @param serverTrust 服务端返回证书
/// @param domain 域名
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(nullable NSString *)domain;

@end

NS_ASSUME_NONNULL_END
