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

+ (instancetype)sharedManager;

/** 系统名称 如：iOS*/
@property (nonatomic, copy) NSString *systemName;
/** 系统版本 */
@property (nonatomic, copy) NSString *systemVersion;
/** 手机设备名称 */
@property (nonatomic, copy) NSString *deviceName;
/** 系统语言 */
@property (nonatomic, copy) NSString *language;
/** 设备类型 如：iPhone、iPod */
@property (nonatomic, copy) NSString *model;
/** app标识 */
@property (nonatomic, copy) NSString *bundleId;
/** 设备型号 如：iPhone9,1 */
@property (nonatomic, copy) NSString *deviceModel;
/** app版本号 */
@property (nonatomic, copy) NSString *appVersion;
/** 编译版本 */
@property (nonatomic, copy) NSString *appBulidVersion;
/** 系统版本 */
@property (nonatomic, copy) NSString *osVersion;
/** idfv */
@property (nonatomic, copy) NSString *idfv;
/** 时区 */
@property (nonatomic, copy) NSString *timeZone;
/** 运营商 */
@property (nonatomic, copy) NSString *carrierName;
/** 屏幕宽度 */
@property (nonatomic, assign) CGFloat screenWidth;
/** 屏幕高度 */
@property (nonatomic, assign) CGFloat screenHeight;

@end


