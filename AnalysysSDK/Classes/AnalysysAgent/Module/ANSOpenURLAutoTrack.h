//
//  ANSOpenURLAutoTrack.h
//  AnalysysAgent
//
//  Created by SoDo on 2018/12/6.
//  Copyright © 2018 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class
 * ANSOpenURLAutoTrack
 *
 * @abstract
 * 自动跟踪App通过web或第三方调起
 *
 * @discussion
 * 处理其他App或网页调起当前App所携带的参数信息，跟随page上传
 * 1. web 百度平台 hmsr&hmpl&hmcu
 * 2. web 非百度平台 utm_source&utm_medium&utm_campaign
 * 3. App调起 scheme方式
 */


@interface ANSOpenURLAutoTrack : NSObject

/**
 开启App唤醒监测
 */
+ (void)autoTrack;


/**
 utm参数存储

 @param utmParameters utm
 */
+ (void)saveUtmParameters:(nullable NSDictionary *)utmParameters;

/**
 获取App唤醒时的utm数据

 @return result
 */
+ (nullable NSDictionary *)utmParameters;



@end


