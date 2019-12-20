//
//  ANSLogParamsUtil.m
//  AnalysysAgent
//
//  Created by xiao xu on 2019/10/24.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSLogParamsUtil.h"
#import "ANSSession.h"
#import "ANSConst+private.h"
#import "ANSKeyNameConst.h"
#import "ANSStrategyManager.h"
#import "AnalysysSDK.h"
#import "ANSDeviceInfo.h"
#import "ANSTelephonyNetwork.h"
#import "ANSDataFunc.h"
#import "ANSFileManager.h"
#import "ANSLock.h"
@implementation ANSLogParamsUtil

+ (NSDictionary *)getSuperProperties {
    ANSPropertyLock();
    NSDictionary *superProperties = [ANSFileManager unarchiveSuperProperties];
    ANSPropertyUnlock();
    return superProperties;
}

+ (NSString *)getAppID {
    return [ANSDataFunc getAppId]?:@"";
}

+ (NSString *)getXwho {
    return [ANSDataFunc getId]?:@"";
}

+ (NSNumber *)getXwhen {
    return [ANSDataFunc currentTimeInteval];
}

+ (NSString *)getLib {
    return @"iOS";
}

+ (NSString *)getLibVersion {
    return ANSSDKVersion;
}

+ (NSString *)getPlatform {
    return @"iOS";
}

+ (NSNumber *)getDebug {
    return [NSNumber numberWithInteger:[ANSStrategyManager sharedManager].currentUseDebugMode];
}

+ (NSNumber *)getIsLogin {
    NSString *aliasID = [[AnalysysSDK sharedManager] getCommonProperties][ANSAlias];
    if (aliasID.length > 0) {
        return [NSNumber numberWithBool:YES];
    }
    return [NSNumber numberWithBool:NO];
}

+ (NSString *)getChannel {
    return [ANSDataFunc getChannel];
}

+ (NSString *)getTimeZone {
    return [ANSDeviceInfo getTimeZone]?:@"";
}

+ (NSString *)getManufacturer {
    return @"Apple";
}

+ (NSString *)getAppVersion {
    return [ANSDeviceInfo getAppVersion]?:@"";
}
+ (NSString *)getModel {
    return [ANSDeviceInfo getDeviceModel]?:@"";
}

+ (NSString *)getOS {
    return @"iOS";
}

+ (NSString *)getOSVersion {
    return [ANSDeviceInfo getOSVersion]?:@"";
}

+ (NSString *)getNetwork {
    return [[ANSTelephonyNetwork shareInstance] telephonyNetworkDescrition]?:@"";
}

+ (NSString *)getCarrierName {
    return [ANSDeviceInfo getCarrierName]?:@"";
}

+ (NSNumber *)getScreenWidth {
    return [NSNumber numberWithFloat:[ANSDeviceInfo getScreenWidth]];
}

+ (NSNumber *)getScreenHeight {
    return [NSNumber numberWithFloat:[ANSDeviceInfo getScreenHeight]];
}

+ (NSString *)getBrand {
    return @"Apple";
}

+ (NSString *)getLanguage {
    return [ANSDeviceInfo getDeviceLanguage]?:@"";
}

+ (NSNumber *)getIsFirstDay {
    return [ANSDataFunc isFirstDayStart];
}

+ (NSString *)getSessionID {
    return [[ANSSession shareInstance] sessionId];
}
@end
