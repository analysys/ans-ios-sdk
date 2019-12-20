//
//  ANSDeviceInfo.h
//  AnalysysAgent
//
//  Created by SoDo on 2018/11/22.
//  Copyright © 2018 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * @class
 * ANSDeviceInfo
 *
 * @abstract
 * 设备模块：设备信息
 *
 * @discussion
 * 获取设备基本信息
 */


@interface ANSDeviceInfo : NSObject

/** 系统名称 */
+ (NSString *)getSystemName;

/** 系统版本 */
+ (NSString *)getSystemVersion;

/** 设备名称 */
+ (NSString *)getDeviceName;

/** 设备语言 */
+ (NSString *)getDeviceLanguage;

/** 设备型号 */
+ (NSString *)getModel;

/** bundleId */
+ (NSString *)getBundleId;

/** 设备类型 */
+ (NSString *)getDeviceModel;

/** app version */
+ (NSString *)getAppVersion;

/** app build版本 */
+ (NSString *)getAppBuildVersion;

/** 系统版本 */
+ (NSString *)getOSVersion;

/** idfv */
+ (NSString *)getIdfv;

/** idfa */
+ (NSString *)getIDFA;

/** 设备标识 */
+ (NSString *)getDeviceID;

/** 屏幕宽度 */
+ (CGFloat)getScreenWidth;

/** 屏幕高度 */
+ (CGFloat)getScreenHeight;

/** 时区 */
+ (NSString *)getTimeZone;

/** 运营商信息 */
+ (NSString *)getCarrierName;

@end


