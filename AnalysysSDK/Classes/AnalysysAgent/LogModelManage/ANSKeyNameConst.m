//
//  ANSKeyNameConst.m
//  AnalysysAgent
//
//  Created by xiao xu on 2019/10/24.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSKeyNameConst.h"

@implementation ANSKeyNameConst

#pragma mark --- 事件日志名字段 ---
NSString *const ANSUserClick = @"$user_click";
NSString *const ANSAlias = @"$alias";

#pragma mark --- 所有日志公共字段 ---
/** $lib */
NSString *const ANSLib = @"$lib";

/** $lib_version */
NSString *const ANSLibVersion = @"$lib_version";

/** $platform */
NSString *const ANSPlatform = @"$platform";

/** $debug */
NSString *const ANSDebug = @"$debug";

/** $is_login */
NSString *const ANSIsLogin = @"$is_login";

#pragma mark --- 全埋点日志字段 ---
/** $channel */
NSString *const ANSChannel = @"$channel";

/** $time_zone */
NSString *const ANSTimeZone = @"$time_zone";

/** $manufacturer */
NSString *const ANSManufacturer = @"$manufacturer";

/** $app_version */
NSString *const ANSAppVersion = @"$app_version";

/** $model */
NSString *const ANSModel = @"$model";

/** $os */
NSString *const ANSOS = @"$os";

/** $os_version */
NSString *const ANSOSVersion = @"$os_version";

/** $network */
NSString *const ANSNetwork = @"$network";

/** $carrier_name */
NSString *const ANSCarrierName = @"$carrier_name";

/** $screen_width */
NSString *const ANSScreenWidth = @"$screen_width";

/** $screen_height */
NSString *const ANSScreenHeight = @"$screen_height";

/** $page_width */
NSString *const ANSPageWidth = @"$page_width";

/** $page_height */
NSString *const ANSPageHeight = @"$page_height";

/** $brand */
NSString *const ANSBrand = @"$brand";

/** $language */
NSString *const ANSLanguage = @"$language";

/** $is_first_day */
NSString *const ANSIsFirstDay = @"$is_first_day";

/** $session_id */
NSString *const ANSSessionID = @"$session_id";

/** $url */
NSString *const ANSUrl = @"$url";

/** $title */
NSString *const ANSTitle = @"$title";

/** $screen_name */
NSString *const ANSScreenName = @"$screen_name";

/** $element_id */
NSString *const ANSElementID = @"$element_id";

/** $element_type */
NSString *const ANSElementType = @"$element_type";

/** $element_path */
NSString *const ANSElementPath = @"$element_path";

/** $element_content */
NSString *const ANSElementContent = @"$element_content";

/** $element_position */
NSString *const ANSElementPosition = @"$element_position";

@end
