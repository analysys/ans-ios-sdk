//
//  ANSControllerUtils.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/10/16.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ANSControllerUtils : NSObject


/// 系统内置类
+ (NSArray *)systemBuildInClasses;

/// 获取当前页面VC
+ (UIViewController *)currentViewController;

/// 根据视图获取页面VC
/// @param view 点击视图
+ (UIViewController *)findViewControllerByView:(UIView *)view;

/// 获取控制器title
/// @param viewController  当前控制器
+ (NSString *)titleFromViewController:(UIViewController *)viewController;

/// 获取视图中所有子控件内容 $appClick事件用到
/// @param view 子视图内容'-'连接 字符串
+ (NSString *)contentFromView:(UIView *)view;

/// 当前根视图
+ (UIViewController *)rootViewController;

/// 获取当前堆栈所有页面
+ (NSArray *)allShowViewControllers;

@end

NS_ASSUME_NONNULL_END
