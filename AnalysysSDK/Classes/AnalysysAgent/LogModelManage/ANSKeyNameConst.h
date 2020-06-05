//
//  ANSKeyNameConst.h
//  AnalysysAgent
//
//  Created by xiao xu on 2019/10/24.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * 日志中对应的字段(Key)
 */
@interface ANSKeyNameConst : NSObject

#pragma mark --- 事件日志名字段 ---
extern NSString *const ANSUserClick;
extern NSString *const ANSAlias;

#pragma mark --- 所有日志公共字段 ---
/** $lib */
extern NSString *const ANSLib;

/** $lib_version */
extern NSString *const ANSLibVersion;

/** $platform */
extern NSString *const ANSPlatform;

/** $debug */
extern NSString *const ANSDebug;

/** $is_login */
extern NSString *const ANSIsLogin;

#pragma mark --- 全埋点日志字段 ---
/** $channel */
extern NSString *const ANSChannel;

/** $time_zone */
extern NSString *const ANSTimeZone;

/** $manufacturer */
extern NSString *const ANSManufacturer;

/** $app_version */
extern NSString *const ANSAppVersion;

/** $model */
extern NSString *const ANSModel;

/** $os */
extern NSString *const ANSOS;

/** $os_version */
extern NSString *const ANSOSVersion;

/** $network */
extern NSString *const ANSNetwork;

/** $carrier_name */
extern NSString *const ANSCarrierName;

/** $screen_width */
extern NSString *const ANSScreenWidth;

/** $screen_height */
extern NSString *const ANSScreenHeight;

/** $page_width */
extern NSString *const ANSPageWidth;

/** $page_height */
extern NSString *const ANSPageHeight;

/** $brand */
extern NSString *const ANSBrand;

/** $language */
extern NSString *const ANSLanguage;

/** $is_first_day */
extern NSString *const ANSIsFirstDay;

/** $session_id */
extern NSString *const ANSSessionID;

/** $url */
extern NSString *const ANSUrl;

/** $title */
extern NSString *const ANSTitle;

/** $screen_name */
extern NSString *const ANSScreenName;

/** $element_id */
extern NSString *const ANSElementID;

/** $element_type */
extern NSString *const ANSElementType;

/** $element_path */
extern NSString *const ANSElementPath;

/** $element_content */
extern NSString *const ANSElementContent;

/** $element_position */
extern NSString *const ANSElementPosition;

@end
