//
//  ANSDataFunc.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSDataFunc.h"

#import "AnalysysSDK.h"
#import "ANSDeviceInfo.h"
#import "ANSTelephonyNetwork.h"
#import "ANSSession.h"
#import "ANSStrategyManager.h"
#import "ANSFileManager.h"

#import "ANSUtil.h"
#import "ANSConst.h"


@implementation ANSDataFunc {
    NSDateFormatter *_dateFmt;
    NSUserDefaults *_userDefaults;
}

/** 若想调用规则方法 必须使用此命名方法 单例，对应ANSDataProcessing中反射方法 */
+ (instancetype)sharedManager {
    static id singleInstance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        singleInstance = [[self alloc] init] ;
    });
    return singleInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dateFmt = [[NSDateFormatter alloc] init];
        _dateFmt.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        _dateFmt.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

#pragma mark *** SDK信息 ***

- (NSString *)getAppId {
    return AnalysysConfig.appKey;
}

- (NSString *)getChannel {
    return AnalysysConfig.channel ?: @"App Store";;
}

- (NSString *)getLibVersion {
    return ANSSDKVersion;
}

- (NSNumber *)currentTimeInteval {
    long long now  = [ANSUtil currentTimeMillisecond];
    NSNumber *different = [ANSFileManager sharedManager].normalProperties[ANSServerTimeInterval];
    if (!different) {
        return @(now);
    }
    long long serverDifferent = [different longLongValue];
    return @(now + serverDifferent);
}

#pragma mark *** 设备信息 ***

- (NSString *)getAppVersion {
    return [ANSDeviceInfo sharedManager].appVersion;
}

- (NSString *)getTimeZone {
    return [ANSDeviceInfo sharedManager].timeZone;
}

- (NSString *)getDeviceModel {
    return [ANSDeviceInfo sharedManager].model;
}

- (NSString *)getOSVersion {
    return [ANSDeviceInfo sharedManager].osVersion;
}

- (NSString *)getCarrierName {
    return [ANSDeviceInfo sharedManager].carrierName;
}

- (CGFloat)getScreenWidth {
    return [ANSDeviceInfo sharedManager].screenWidth;
}

- (CGFloat)getScreenHeight {
    return [ANSDeviceInfo sharedManager].screenHeight;
}

- (NSString *)getDeviceLanguage {
    return [ANSDeviceInfo sharedManager].language;
}

- (NSInteger)getDebugMode {
    return [ANSStrategyManager sharedManager].currentUseDebugMode;
}

- (NSString *)getNetwork {
    return [ANSTelephonyNetwork shareInstance].telephonyNetworkDescrition;
}

- (BOOL)isTimeCalibration {
    NSNumber *different = [ANSFileManager sharedManager].normalProperties[ANSServerTimeInterval];
    if (different) {
        return YES;
    }
    return NO;
}

- (NSString *)getIDFA {
    @try {
        NSString *idfa = nil;
        Class identifierManager = NSClassFromString(@"ASIdentifierManager");
        if (identifierManager) {
            SEL sharedManagerSel = NSSelectorFromString(@"sharedManager");
            if ([identifierManager respondsToSelector:sharedManagerSel]) {
                id manager = ((id (*)(id, SEL))[identifierManager methodForSelector:sharedManagerSel])(identifierManager, sharedManagerSel);
                SEL trackEnableSel = NSSelectorFromString(@"isAdvertisingTrackingEnabled");
                BOOL isTrackingEnable = ((BOOL (*)(id, SEL))[manager methodForSelector:trackEnableSel])(manager, trackEnableSel);
                if (isTrackingEnable) {
                    SEL advertisingIdentifierSel = NSSelectorFromString(@"advertisingIdentifier");
                    NSUUID *uuid = ((NSUUID* (*)(id, SEL))[manager methodForSelector:advertisingIdentifierSel])(manager, advertisingIdentifierSel);
                    idfa = [uuid UUIDString];
                    return idfa;
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"********** [Analysys] [Debug] %@ **********", exception.description);
    }
    
    return nil;
}

- (NSString *)getIDFV {
    if (NSClassFromString(@"UIDevice")) {
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    return nil;
}

#pragma mark *** 用户信息 ***

- (NSString *)getId {
    ANSFileManager *fileManager = [ANSFileManager sharedManager];
    NSString *aliasID = fileManager.normalProperties[ANSAlias];
    NSString *anonymousId = fileManager.normalProperties[ANSAnonymousId];
    NSString *xwho;
    if (aliasID.length > 0) {
        xwho = aliasID;
    } else if (anonymousId.length > 0) {
        xwho = anonymousId;
    } else {
        xwho = fileManager.normalProperties[ANSUUID];
    }
    return xwho;
}

- (BOOL)isBackgroundStart {
    return [AnalysysSDK sharedManager].isBackgroundActive;
}

- (BOOL)isLogin {
    ANSFileManager *fileManager = [ANSFileManager sharedManager];
    NSString *aliasID = fileManager.normalProperties[ANSAlias];
    if (aliasID.length > 0) {
        return YES;
    }
    return NO;
}

- (NSString *)getSessionId {
    return [ANSSession shareInstance].sessionId;
}

#pragma mark *** other ***

- (NSNumber *)getAppDuration {
    return [[AnalysysSDK sharedManager] appDuration];
}

/** 首次运行 */
- (BOOL)isFirstTimeStart {
    NSString *firstStartDate = [[NSUserDefaults standardUserDefaults] objectForKey:ANSAppLaunchDate];
    BOOL isFirstStart = NO;
    if (firstStartDate == nil) {
        isFirstStart = YES;
        firstStartDate = [_dateFmt stringFromDate:[NSDate date]];
        [_userDefaults setObject:firstStartDate forKey:ANSAppLaunchDate];
        [_userDefaults synchronize];
    }
    return isFirstStart;
}

/** 首天启动 */
- (BOOL)isFirstDayStart {
    NSString *firstStartDate = [[NSUserDefaults standardUserDefaults] objectForKey:ANSAppLaunchDate];
    NSString *dateStr = [[_dateFmt stringFromDate:[NSDate date]] substringToIndex:10];
    if ([dateStr isEqualToString:[firstStartDate substringToIndex:10]]) {
        return YES;
    }
    return NO;
}




@end
