//
//  ANSLogParamsUtil.h
//  AnalysysAgent
//
//  Created by xiao xu on 2019/10/24.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
/**
 * 用来获取日志参数中的值
 */
@interface ANSLogParamsUtil : NSObject

#pragma mark --- 获取用户设置的属性 ---
+ (NSDictionary *)getSuperProperties;

#pragma mark --- 获取通用属性 ---
+ (NSString *)getAppID;
+ (NSString *)getXwho;
+ (NSNumber *)getXwhen;

+ (NSString *)getLib;
+ (NSString *)getLibVersion;
+ (NSString *)getPlatform;
+ (NSNumber *)getDebug;
+ (NSNumber *)getIsLogin;

+ (NSString *)getChannel;
+ (NSString *)getTimeZone;
+ (NSString *)getManufacturer;
+ (NSString *)getAppVersion;
+ (NSString *)getModel;
+ (NSString *)getOS;
+ (NSString *)getOSVersion;
+ (NSString *)getNetwork;
+ (NSString *)getCarrierName;
+ (NSNumber *)getScreenWidth;
+ (NSNumber *)getScreenHeight;
+ (NSString *)getBrand;
+ (NSString *)getLanguage;
+ (NSNumber *)getIsFirstDay;
+ (NSString *)getSessionID;

@end

NS_ASSUME_NONNULL_END
