//
//  AppDelegate.m
//  AnalysysDemo
//
//  Created by SoDo on 2019/8/7.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "AppDelegate.h"

#import <AnalysysSDK/AnalysysAgent.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
        
    
    [self _initAnalysysSDK];
    
    
    return YES;
}

- (void)_initAnalysysSDK {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    //  部分设置在SDK初始化前设置
    //    [AnalysysAgent identify:@"testIdentify"];
    
//    //  页面自动采集
//    [AnalysysAgent setAutomaticCollection:YES];
//    //  热图采集
//    [AnalysysAgent setAutomaticHeatmap:YES];
//    //  全埋点事件
//    [AnalysysAgent setAutoTrackClick:YES];
    
    //  默认的 debugmode = debugoff 不打印log，可在上传日志中查看是否成功
    //    [AnalysysAgent registerSuperProperties:@{@"Sex": @"male", @"bobby": @[@"football",@"pingpang"]}];
    
    //  AnalysysAgent SDK配置信息
    AnalysysConfig.appKey = @"datacollection";
    AnalysysConfig.channel = @"App Store";
//    AnalysysConfig.autoProfile = YES;
//    AnalysysConfig.autoInstallation = YES;
    AnalysysConfig.encryptType = AnalysysEncryptAESCBC128;
//    AnalysysConfig.allowTimeCheck = YES;
//    AnalysysConfig.maxDiffTimeInterval = 5 * 60;
    [AnalysysAgent startWithConfig:AnalysysConfig];
    
    
    //**********  务必将debug及上传地址放置到 startWithConfig: 之后，否则可能无法正常上报数据  ********//
#if DEBUG
    [AnalysysAgent setDebugMode:AnalysysDebugButTrack];
#else
    [AnalysysAgent setDebugMode:AnalysysDebugOff];
#endif
    
    [AnalysysAgent setUploadURL:@"http://192.168.220.105:8089"];
    
    
    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
    NSLog(@"The code execution time %f ms", linkTime *1000.0);
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


#pragma mark - App跳转

/** 9.0及之前 */
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"^^^^^^^^^^^ %s",__FUNCTION__);
    NSLog(@"url:%@",url.absoluteString);
    NSLog(@"host:%@",url.host);
    
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

#pragma mark - 3D touch进入

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    
    // 1.获得shortcutItem的type type就是初始化shortcutItem的时候传入的唯一标识符
    NSString *type = shortcutItem.type;
    //2.可以通过type来判断点击的是哪一个快捷按钮 并进行每个按钮相应的点击事件
    if ([type isEqualToString:@"HomePage"]) {
        // do something
    } else {
        // do something
    }
}

#pragma mark - 通用链接
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    
    NSLog(@"userActivity: %@", userActivity);
    
    return YES;
}


@end
