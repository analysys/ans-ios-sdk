//
//  ANSConst.h
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

#pragma mark *** 事件类型 ***
/** App启动 */
extern NSString *const ANSAppStart;
/** 页面事件 */
extern NSString *const ANSPageView;
/** track事件 */
extern NSString *const ANSTrack;
/** 身份标识 */
extern NSString *const ANSAlias;
/** 匿名标识 */
extern NSString *const ANSAnonymousId;
/** 默认标识 */
extern NSString *const ANSUUID;
/** 原始标识 */
extern NSString *const ANSOriginalId;
/** profile */
extern NSString *const ANSProfileSet;
/** profile_set_once */
extern NSString *const ANSProfileSetOnce;
/** profile_increment */
extern NSString *const ANSProfileIncrement;
/** profile_append */
extern NSString *const ANSProfileAppend;
/** profile_unset */
extern NSString *const ANSProfileUnset;
/** profile_delete */
extern NSString *const ANSProfileDelete;
/** App退出 */
extern NSString *const ANSAppEnd;

/** 热图 */
extern NSString *const ANSHeatMap;

#pragma mark *** other ***

/** App启动标识 */
extern NSString *const ANSAppLaunchDate;
/** profile系列模板 */
extern NSString *const ANSProfileSetXXX;
/** 服务器时间校准 */
extern NSString *const ANSServerTimeInterval;



@end
