//
//  Analysys_CMB.h
//  Analysys_CMB
//
//  Created by SoDo on 2019/3/10.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Analysys_CMB : NSObject

/**
 跟踪App启动方式
 
 @param delegate 遵循<UIApplicationDelegate>协议的类
 @param launchOptions 启动参数
 */
+ (void)monitorAppDelegate:(id<UIApplicationDelegate>)delegate launchOptions:(NSDictionary *)launchOptions;

@end


