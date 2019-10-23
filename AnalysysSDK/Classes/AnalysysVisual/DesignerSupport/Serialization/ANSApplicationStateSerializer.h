//
//  ANSApplicationStateSerializer.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

/**
 * @class
 * @abstract 配置及snapshot管理
 *
 * snapshot 中图层结构获取
 */

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@class ANSObjectSerializerConfig;
@class ANSObjectIdentityProvider;

@interface ANSApplicationStateSerializer : NSObject


/**
 初始化管理类

 @param application 当前application实例
 @param configuration 配置信息对象
 @param objectIdentityProvider 对象标识生成器
 @return 实例
 */
- (instancetype)initWithApplication:(UIApplication *)application configuration:(ANSObjectSerializerConfig *)configuration objectIdentityProvider:(ANSObjectIdentityProvider *)objectIdentityProvider;

/** 当前截屏 */
- (UIImage *)screenshotImageForWindowAtIndex:(NSUInteger)index;

/** 图层结构列表 */
- (NSDictionary *)objectHierarchyForWindowAtIndex:(NSUInteger)index;


@end
