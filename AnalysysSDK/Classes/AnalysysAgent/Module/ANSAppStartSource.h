//
//  ANSAppStartSource.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/10/25.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ANSAppStartSource : NSObject


+ (instancetype)sharedManager;

/// 检测App启动方式
/// @param delegate AppDelegate对象
/// @param launchOptions 启动参数
- (void)startMonitorAppDelegate:(id<UIApplicationDelegate>)delegate launchOptions:(NSDictionary *)launchOptions;


@end


