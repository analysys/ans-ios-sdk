//
//  AppDelegate.m
//  EGAnalyticsDemo
//
//  Created by analysys on 2018/2/3.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "AppDelegate.h"

#import <AnalysysAgent/AnalysysAgent.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    [self _initAnalysysSDK];
    
    return YES;
}

- (void)_initAnalysysSDK {
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
#if DEBUG
    [AnalysysAgent setDebugMode:AnalysysDebugButTrack];
#else
    [AnalysysAgent setDebugMode:AnalysysDebugOff];
#endif
    
    [AnalysysAgent setUploadURL:<#url#>];
    
    //  AnalysysAgent SDK配置信息
    AnalysysConfig.appKey = <#appkey#>;
    AnalysysConfig.channel = @"App Store";
    AnalysysConfig.autoProfile = YES;
    AnalysysConfig.autoInstallation =  YES;
    AnalysysConfig.encryptType = AnalysysEncryptAES;
    AnalysysConfig.allowTimeCheck = YES;
    AnalysysConfig.maxDiffTimeInterval = 5 * 60;
    //  使用配置信息初始化SDK
    [AnalysysAgent startWithConfig:AnalysysConfig];
    
//#if DEBUG
//    [AnalysysAgent setVisitorDebugURL:<#wsurl#>];
//#endif
//    [AnalysysAgent setVisitorConfigURL:<#configurl#>];
    
    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
    NSLog(@"The code execution time %f ms", linkTime *1000.0);
    
}


#pragma mark *** App跳转 ***

/** 9.0及之前 */
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"^^^^^^^^^^^ %s",__FUNCTION__);
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"^^^^^^^^^^^ %s",__FUNCTION__);
    
    return YES;
}

/** 9.0之后 */
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@"^^^^^^^^^^^ %s",__FUNCTION__);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
