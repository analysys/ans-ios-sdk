//
//  AnalysysPush.h
//  AnalysysAgent
//
//  Created by analysys on 2018/5/31.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class
 * AnalysysPush
 *
 * @abstract
 * 推送模块：统计推送到达及点击行为
 *
 * @discussion
 * 通过易观平台配置推送信息后，使用当前类统计推送具体行为情况
 */

@interface AnalysysPush : NSObject


/**
 解析易观推动

 @param userInfo 推送消息
 @return 易观推广活动信息
 */
+ (NSDictionary *)parseAnsPushInfo:(id)userInfo;

/**
 拼接context数据

 @param pushInfo 活动信息
 @return 字典
 */
+ (NSDictionary *)spliceContextWithPushInfo:(NSDictionary *)pushInfo;


/**
 点击活动通知

 @param pushInfo 活动信息
 */
+ (void)clickAnsPushInfo:(NSDictionary *)pushInfo;




@end
