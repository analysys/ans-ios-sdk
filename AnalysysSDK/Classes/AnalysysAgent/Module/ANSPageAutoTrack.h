//
//  ANSPageAutoTrack.h
//  AnalysysAgent
//
//  Created by SoDo on 2018/12/10.
//  Copyright © 2018 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class
 * ANSPageAutoTrack
 *
 * @abstract
 * 自动跟踪页面切换
 *
 * @discussion
 * 采集页面打开及关闭，根据设置是否跟踪上传页面事件
 * 同时进行session切换判断
 */


@interface ANSPageAutoTrack : NSObject

+ (instancetype)shareInstance;

/**
 开启页面切换监测
 */
+ (void)autoTrack;

/**
 跟踪页面最后访问的页面
 */
+ (void)autoTrackLastVisitPage;


@end


