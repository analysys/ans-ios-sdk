//
//  ANSDataFunc.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class
 * ANSDataFunc
 *
 * @abstract
 * 配置中通过方法获取的数据 的实现类
 *
 * @discussion
 * 该类中的方法名称必须与规则配置文件中 value 的方法名称对应
 * 如：ANSDataFunc.getAppId
 */


@interface ANSDataFunc : NSObject

+ (NSString *)getAppId;
+ (NSString *)getChannel;
+ (NSString *)getLibVersion;
+ (NSString *)getId;
+ (NSNumber *)currentTimeInteval;
+ (NSNumber *)isFirstDayStart;
+ (NSString *)getDeviceId;

@end

