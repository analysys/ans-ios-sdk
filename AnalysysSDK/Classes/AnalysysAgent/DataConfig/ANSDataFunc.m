//
//  ANSDataFunc.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSDataFunc.h"

#import "AnalysysSDK.h"
#import "AnalysysAgentConfig.h"
#import "ANSTelephonyNetwork.h"
#import "ANSSession.h"
#import "ANSStrategyManager.h"
#import "ANSFileManager.h"

#import "ANSUtil.h"
#import "ANSConst+private.h"
#import "ANSDateUtil.h"
#import "ANSDeviceInfo.h"

@implementation ANSDataFunc

#pragma mark - SDK信息

+ (NSString *)getAppId {
    return AnalysysConfig.appKey;
}

+ (NSString *)getChannel {
    return AnalysysConfig.channel ?: @"App Store";
}

+ (NSString *)getLibVersion {
    return ANSSDKVersion;
}

+ (NSNumber *)currentTimeInteval {
    long long timeInterval = [ANSUtil nowTimeMilliseconds];
    return [NSNumber numberWithLongLong:timeInterval];
}


+ (NSInteger)getDebugMode {
    return [ANSStrategyManager sharedManager].currentUseDebugMode;
}

+ (NSString *)getNetwork {
    return [ANSTelephonyNetwork shareInstance].telephonyNetworkDescrition;
}

+ (NSNumber *)isTimeCalibration {
    // 默认未校准，上传时修改该值
    return [NSNumber numberWithBool:NO];
}

#pragma mark - 用户信息

+ (NSString *)getId {
    NSString *xwho = [[AnalysysSDK sharedManager] getXwho];
    return xwho;
}

+ (NSNumber *)isBackgroundStart {
    return [NSNumber numberWithBool:[AnalysysSDK sharedManager].isBackgroundActive];
}

+ (NSNumber *)isLogin {
    NSString *aliasID = [[AnalysysSDK sharedManager] getCommonProperties][ANSEventAlias];
    if (aliasID.length > 0) {
        return [NSNumber numberWithBool:YES];
    }
    return [NSNumber numberWithBool:NO];
}

+ (NSString *)getSessionId {
    return [ANSSession shareInstance].sessionId;
}

+ (NSNumber *)getAppDuration {
    long long appDur = [AnalysysSDK sharedManager].appDuration;
    if (appDur < 0) {
        appDur = 0;
    }
    return [NSNumber numberWithLongLong:appDur];
}

/** 首次运行 */
+ (NSNumber *)isFirstTimeStart {
    NSString *firstStartDate = [ANSFileManager userDefaultValueWithKey:ANSAppLaunchDate];
    BOOL isFirstStart = NO;
    if (!firstStartDate) {
        isFirstStart = YES;
        firstStartDate = [[ANSDateUtil dateFormat] stringFromDate:[NSDate date]];
        [ANSFileManager saveUserDefaultWithKey:ANSAppLaunchDate value:firstStartDate];
    }
    return [NSNumber numberWithBool:isFirstStart];
}

/** 首天启动 */
+ (NSNumber *)isFirstDayStart {
    NSString *firstStartDate = [ANSFileManager userDefaultValueWithKey:ANSAppLaunchDate];
    NSString *dateStr = [[[ANSDateUtil dateFormat] stringFromDate:[NSDate date]] substringToIndex:10];
    if (!firstStartDate || [dateStr isEqualToString:[firstStartDate substringToIndex:10]]) {
        return [NSNumber numberWithBool:YES];
    }
    return [NSNumber numberWithBool:NO];
}

/// 设备标识 idfa > idfv > uuid
+ (NSString *)getDeviceId {
    if (!AnalysysConfig.autoTrackDeviceId) {
        return nil;
    }
    NSString *idfa = [ANSDeviceInfo getIDFA];
    if (idfa) {
        return idfa;
    } else {
        NSString *idfv = [ANSDeviceInfo getIdfv];
        return idfv ?: [[NSUUID UUID] UUIDString];
    }
}


@end
