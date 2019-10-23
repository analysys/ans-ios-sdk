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

#import "ANSUtil.h"
#import "ANSConst+private.h"

static NSDateFormatter *dateFormatter = nil;

@implementation ANSDataFunc

#pragma mark - SDK信息

+ (NSString *)getAppId {
    return AnalysysConfig.appKey;
}

+ (NSString *)getChannel {
    return AnalysysConfig.channel ?: @"App Store";;
}

+ (NSString *)getLibVersion {
    return ANSSDKVersion;
}

+ (NSNumber *)currentTimeInteval {
    long long now = [ANSUtil nowTimeMilliseconds];
    NSNumber *different = [[AnalysysSDK sharedManager] getCommonProperties][ANSServerTimeInterval];
    if (different == nil) {
        return [NSNumber numberWithLongLong:now];
    }
    long long serverDifferent = [different longLongValue];
    long long timeInterval = now + serverDifferent;
    if (timeInterval < INT_MAX) {
        timeInterval = now;
    }
    return [NSNumber numberWithLongLong:timeInterval];
}


+ (NSInteger)getDebugMode {
    return [ANSStrategyManager sharedManager].currentUseDebugMode;
}

+ (NSString *)getNetwork {
    return [ANSTelephonyNetwork shareInstance].telephonyNetworkDescrition;
}

+ (NSNumber *)isTimeCalibration {
    NSNumber *different = [[AnalysysSDK sharedManager] getCommonProperties][ANSServerTimeInterval];
    if (different != nil) {
        return [NSNumber numberWithBool:YES];
    }
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
    return [[AnalysysSDK sharedManager] appDuration];
}

/** 首次运行 */
+ (NSNumber *)isFirstTimeStart {
    [[AnalysysSDK getUserDefaultLock] lock];
    NSString *firstStartDate = [[[NSUserDefaults standardUserDefaults] objectForKey:ANSAppLaunchDate] copy];
    [[AnalysysSDK getUserDefaultLock] unlock];
    BOOL isFirstStart = NO;
    if (firstStartDate == nil) {
        isFirstStart = YES;
        firstStartDate = [[self dateFormat] stringFromDate:[NSDate date]];
        [[AnalysysSDK getUserDefaultLock] lock];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:firstStartDate forKey:ANSAppLaunchDate];
        [defaults synchronize];
        [[AnalysysSDK getUserDefaultLock] unlock];
    }
    return [NSNumber numberWithBool:isFirstStart];
}

/** 首天启动 */
+ (NSNumber *)isFirstDayStart {
    [[AnalysysSDK getUserDefaultLock] lock];
    NSString *firstStartDate = [[[NSUserDefaults standardUserDefaults] objectForKey:ANSAppLaunchDate] copy];
    [[AnalysysSDK getUserDefaultLock] unlock];
    NSString *dateStr = [[[self dateFormat] stringFromDate:[NSDate date]] substringToIndex:10];
    if (!firstStartDate || [dateStr isEqualToString:[firstStartDate substringToIndex:10]]) {
        return [NSNumber numberWithBool:YES];
    }
    return [NSNumber numberWithBool:NO];
}

#pragma mark - other

+ (NSDateFormatter *)dateFormat {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    });
    return dateFormatter;
}


@end
