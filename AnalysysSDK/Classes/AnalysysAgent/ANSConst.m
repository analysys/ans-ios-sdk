//
//  ANSConst.m
//  AnalysysAgent
//
//  Created by analysys on 2018/6/20.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "ANSConst+private.h"

@implementation ANSConst

NSString *const ANSSDKVersion = @"4.5.1";

#pragma mark - 基础字段

NSString *const ANSAppid = @"appid";
NSString *const ANSXwho = @"xwho";
NSString *const ANSXwhen = @"xwhen";
NSString *const ANSXwhat = @"xwhat";
NSString *const ANSXcontext = @"xcontext";

#pragma mark - 事件类型标识

NSString *const ANSEventAppStart = @"$startup";
NSString *const ANSEventAppEnd = @"$end";
NSString *const ANSEventPageView = @"$pageview";
NSString *const ANSEventTrack = @"$track";
NSString *const ANSEventCrash = @"$app_crash";

NSString *const ANSEventAlias = @"$alias";

NSString *const ANSEventProfileSet = @"$profile_set";
NSString *const ANSEventProfileSetOnce = @"$profile_set_once";
NSString *const ANSEventProfileIncrement = @"$profile_increment";
NSString *const ANSEventProfileAppend = @"$profile_append";
NSString *const ANSEventProfileUnset = @"$profile_unset";
NSString *const ANSEventProfileDelete = @"$profile_delete";

NSString *const ANSEventInstallation = @"$first_installation";

NSString *const ANSEventHeatMap = @"$app_click";

NSString *const ANSEventPush = @"push";

#pragma mark - 通用预置属性
NSString *const ANSPresetTimeZone = @"$time_zone";
NSString *const ANSPresetPlatform = @"$platform";
NSString *const ANSPresetAppVersion = @"$app_version";
NSString *const ANSPresetLanguage = @"$language";
NSString *const ANSPresetLibVersion = @"$lib_version";
NSString *const ANSPresetLib = @"$lib";
NSString *const ANSPresetScreenWidth = @"$screen_width";
NSString *const ANSPresetScreenHeight = @"$screen_height";
NSString *const ANSPresetNetwork = @"$network";
NSString *const ANSPresetManufacturer = @"$manufacturer";
NSString *const ANSPresetBrand = @"$brand";
NSString *const ANSPresetModel = @"$model";
NSString *const ANSPresetOS = @"$os";
NSString *const ANSPresetSessionId = @"$session_id";
NSString *const ANSPresetTimeCalibrated = @"$is_time_calibrated";
NSString *const ANSPresetIsFirstTime = @"$is_first_time";
NSString *const ANSPresetIsFirstDay = @"$is_first_day";

// 页面事件
NSString *const ANSPageUrl = @"$url";
NSString *const ANSPageTitle = @"$title";
NSString *const ANSPageReferrerUrl = @"$referrer";

// profile_set_once事件
NSString *const ANSPresetFirstVisitTime = @"$first_visit_time";
NSString *const ANSPresetFirstVisitLanguage = @"$first_visit_language";
NSString *const ANSPresetResetTime = @"$reset_time";

//  profile_set_xxx/alias
NSString *const ANSPresetIDFV = @"$idfv";
NSString *const ANSPresetIDFA = @"$idfa";

#pragma mark - UTM参数
NSString *const ANSUtmCampaignId = @"$utm_campaign_id";
NSString *const ANSUtmCampaign = @"$utm_campaign";
NSString *const ANSUtmMedium = @"$utm_medium";
NSString *const ANSUtmSource = @"$utm_source";
NSString *const ANSUtmContent = @"$utm_content";
NSString *const ANSUtmTerm = @"$utm_term";
NSString *const ANSUtmActionType = @"$actiontype";
NSString *const ANSUtmAction = @"$action";
NSString *const ANSUtmCpd = @"$cpd";

#pragma mark - other

NSString *const ANSAppKey = @"AnalysysAppKey";
NSString *const ANSAnonymousId = @"$distinct_id";
NSString *const ANSUUID = @"eg_uuid";
NSString *const ANSOriginalId = @"$original_id";

NSString *const ANSAppLaunchDate = @"EGAppLaunchedDate";
NSString *const ANSProfileSetXXX = @"$profile_set_xxx";

#pragma mark - 数据库

NSString *const ANSLogJson = @"LogJsonString";
NSString *const ANSLogOldOrNew = @"LogOldOrNew";

@end
