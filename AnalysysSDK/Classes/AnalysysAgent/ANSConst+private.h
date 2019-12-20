//
//  ANSConst+private.h
//  AnalysysAgent
//
//  Created by analysys on 2018/6/20.
//  Copyright © 2018年 analysys. All rights reserved.
//


#import <Foundation/Foundation.h>

/**
 * @class
 * ANSConst
 *
 * @abstract
 * 常量定义
 *
 * @discussion
 * 公共常量、枚举值定义
 */

@interface ANSConst : NSObject

/** SDK版本号 */
extern NSString *const ANSSDKVersion;

#pragma mark - 基础字段
extern NSString *const ANSAppid;
extern NSString *const ANSXwho;
extern NSString *const ANSXwhen;
extern NSString *const ANSXwhat;
extern NSString *const ANSXcontext;

#pragma mark - 事件类型

/** App启动 */
extern NSString *const ANSEventAppStart;
/** App退出 */
extern NSString *const ANSEventAppEnd;
/** 页面事件 */
extern NSString *const ANSEventPageView;
/** track事件 */
extern NSString *const ANSEventTrack;
/** crash事件 */
extern NSString *const ANSEventCrash;

/** 身份标识 */
extern NSString *const ANSEventAlias;

/** profile */
extern NSString *const ANSEventProfileSet;
/** profile_set_once */
extern NSString *const ANSEventProfileSetOnce;
/** profile_increment */
extern NSString *const ANSEventProfileIncrement;
/** profile_append */
extern NSString *const ANSEventProfileAppend;
/** profile_unset */
extern NSString *const ANSEventProfileUnset;
/** profile_delete */
extern NSString *const ANSEventProfileDelete;

/** 渠道追踪 */
extern NSString *const ANSEventInstallation;

/** 热图 */
extern NSString *const ANSEventHeatMap;

/** 推送(虚拟) */
extern NSString *const ANSEventPush;


#pragma mark - 通用预置属性

/** 时区 */
extern NSString *const ANSPresetTimeZone;
/** SDK平台 */
extern NSString *const ANSPresetPlatform;
/** App版本 */
extern NSString *const ANSPresetAppVersion;
/** 语言 */
extern NSString *const ANSPresetLanguage;
/** SDK版本 */
extern NSString *const ANSPresetLibVersion;
/** SDK类型 */
extern NSString *const ANSPresetLib;
/** 屏幕宽度 */
extern NSString *const ANSPresetScreenWidth;
/** 屏幕高度 */
extern NSString *const ANSPresetScreenHeight;
/** 当前网络 */
extern NSString *const ANSPresetNetwork;
/** 设备厂商 */
extern NSString *const ANSPresetManufacturer;
/** 设备品牌 */
extern NSString *const ANSPresetBrand;
/** 设备型号 */
extern NSString *const ANSPresetModel;
/** 操作系统 */
extern NSString *const ANSPresetOS;
/** session标识 */
extern NSString *const ANSPresetSessionId;
/** 时间校准标识 */
extern NSString *const ANSPresetTimeCalibrated;
/** 是否首次访问 */
extern NSString *const ANSPresetIsFirstTime;
/** 是否首天 */
extern NSString *const ANSPresetIsFirstDay;


// 页面事件

/** 页面标识 */
extern NSString *const ANSPageUrl;
/** 页面标题 */
extern NSString *const ANSPageTitle;
/** 页面来源 */
extern NSString *const ANSPageReferrerUrl;

// profile_set_once事件

/** 首次启动时间 */
extern NSString *const ANSPresetFirstVisitTime;
/** 首次启动语言 */
extern NSString *const ANSPresetFirstVisitLanguage;
/** reset时间 */
extern NSString *const ANSPresetResetTime;

//  profile_set_xxx/alias
/** 广告标识 */
extern NSString *const ANSPresetIDFV;
/** 广告标识 */
extern NSString *const ANSPresetIDFA;

#pragma mark - UTM参数
extern NSString *const ANSUtmCampaignId;
extern NSString *const ANSUtmCampaign;
extern NSString *const ANSUtmMedium;
extern NSString *const ANSUtmSource;
extern NSString *const ANSUtmContent;
extern NSString *const ANSUtmTerm;
extern NSString *const ANSUtmActionType;
extern NSString *const ANSUtmAction;
extern NSString *const ANSUtmCpd;

#pragma mark - other

/** appkey */
extern NSString *const ANSAppKey;
/** 匿名标识 */
extern NSString *const ANSAnonymousId;
/** 默认标识 */
extern NSString *const ANSUUID;
/** 原始标识 */
extern NSString *const ANSOriginalId;

/** App启动标识 */
extern NSString *const ANSAppLaunchDate;
/** profile系列模板 */
extern NSString *const ANSProfileSetXXX;

#pragma mark - 数据库
extern NSString *const ANSLogJson;  //  上报日志
extern NSString *const ANSLogOldOrNew;  //  是否本次产生的数据


@end
