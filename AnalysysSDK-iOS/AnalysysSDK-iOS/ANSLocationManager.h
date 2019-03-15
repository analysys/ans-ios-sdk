//
//  ANSLocationManager.h
//  Analysys_CMB
//
//  Created by SoDo on 2019/1/16.
//  Copyright © 2019 analysys. All rights reserved.
//
/**
 * @class
 * ANSLocationManager
 *
 * @abstract
 * 定位
 *
 * @discussion
 * 开启定位
 */
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ANSLocationManager : NSObject

+ (instancetype)shareInstance;

/**
 开启手机定位
 */
- (void)startMonitorLocation;

@end

NS_ASSUME_NONNULL_END
