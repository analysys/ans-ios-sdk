//
//  ANSConst.m
//  AnalysysAgent
//
//  Created by analysys on 2018/6/20.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "ANSConst.h"

@implementation ANSConst

NSString *const ANSSDKVersion = @"4.3.0";

#pragma mark *** 事件类型标识 ***
NSString *const ANSAppStart = @"$startup";
NSString *const ANSPageView = @"$pageview";
NSString *const ANSTrack = @"$track";
NSString *const ANSAlias = @"$alias";
NSString *const ANSAnonymousId = @"$distinct_id";
NSString *const ANSUUID = @"eg_uuid";
NSString *const ANSOriginalId = @"$original_id";
NSString *const ANSProfileSet = @"$profile_set";
NSString *const ANSProfileSetOnce = @"$profile_set_once";
NSString *const ANSProfileIncrement = @"$profile_increment";
NSString *const ANSProfileAppend = @"$profile_append";
NSString *const ANSProfileUnset = @"$profile_unset";
NSString *const ANSProfileDelete = @"$profile_delete";
NSString *const ANSAppEnd = @"$end";

NSString *const ANSHeatMap = @"$app_click";

#pragma mark *** other ***

NSString *const ANSAppLaunchDate = @"EGAppLaunchedDate";
NSString *const ANSProfileSetXXX = @"$profile_set_xxx";

NSString *const ANSServerTimeInterval = @"ANSServerTimeInterval";


@end
