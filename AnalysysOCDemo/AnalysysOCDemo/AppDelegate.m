//
//  AppDelegate.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/17.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "AppDelegate.h"
#import <Bugly/Bugly.h>
#import "ANSTabVC.h"
#import "AnalysysDataCache.h"
#import "AnalysysLogManager.h"

//#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Bugly startWithAppId:@"4b082d4d5e"];
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    
    [self initialAnalysysSDK:launchOptions];
        
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ANSTabVC *tab = [[ANSTabVC alloc] init];
    self.window.rootViewController = tab;
    [self.window makeKeyAndVisible];
    
    [[AnalysysLogManager sharedSingleton] createSuspendButton];
    
    [self requestAdvertisingIdentifier];
    
    return YES;
}


/// demo启用缓存初始化， 为了方便开发者查看日志相关内容
/// 若要使用正常初始化，可参考 _initAnalysysSDKWithOptions: 方法内容
/// @param launchOptions 启动参数
- (void)initialAnalysysSDK:(NSDictionary *)launchOptions {
    
    [AnalysysAgent monitorAppDelegate:self launchOptions:launchOptions];
    
    NSString *appkey = [AnalysysDataCache get_appkey]?:@"heatmaptest0916";
    AnalysysConfig.appKey = appkey;
    
    
    NSString *channel = [AnalysysDataCache get_channel]?:@"App Store";
    AnalysysConfig.channel = channel;
    
    [AnalysysAgent setObserverListener:[AnalysysLogManager sharedSingleton]];
    
    //  初始化方舟SDK
    [AnalysysAgent startWithConfig:AnalysysConfig];
    
#if DEBUG
    [AnalysysAgent setDebugMode:AnalysysDebugButTrack];
#else
    [AnalysysAgent setDebugMode:AnalysysDebugOff];
#endif

    NSString *upload_url = [AnalysysDataCache get_upload_url]?:@"http://192.168.220.105:8089";
    [AnalysysAgent setUploadURL:upload_url];
#if DEBUG
    NSString *debug_url = [AnalysysDataCache get_debug_url]?:@"ws://192.168.220.105:9091";
    [AnalysysAgent setVisitorDebugURL:debug_url];
#endif
    NSString *config_url = [AnalysysDataCache get_config_url]?:@"http://192.168.220.105:8089";
    [AnalysysAgent setVisitorConfigURL:config_url];
    
}


/// 正常方舟初始化代码
/// @param launchOptions 启动参数
- (void)_initAnalysysSDKWithOptions:(NSDictionary *)launchOptions {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    [AnalysysAgent monitorAppDelegate:self launchOptions:launchOptions];
    
    //  部分设置在SDK初始化前设置
    [AnalysysAgent setAutomaticCollection:YES];
    //    [AnalysysAgent setPageViewBlackListByPages:[NSSet setWithObject:@"ANSHomeViewController"]];
    //    [AnalysysAgent setPageViewWhiteListByPages:[NSSet setWithObjects:@"ANSHomeViewController", @"ANSDemoController", nil]];
    
    [AnalysysAgent setAutomaticHeatmap:YES];
    //    [AnalysysAgent setHeatMapBlackListByPages:[NSSet setWithObjects:@"ANSHomeViewController", nil]];
    //    [AnalysysAgent setHeatMapWhiteListByPages:[NSSet setWithObjects:@"ANSHomeViewController", nil]];
    
    [AnalysysAgent setAutoTrackClick:YES];
    //    [AnalysysAgent setAutoClickBlackListByPages:[NSSet setWithObject:@"ANSHomeViewController"]];
    //    [AnalysysAgent setAutoClickWhiteListByPages:[NSSet setWithObject:@"ANSHomeViewController"]];
    
    // 通用属性
    //    [AnalysysAgent registerSuperProperties:@{@"Sex": @"male", @"bobby": @[@"football",@"pingpang"]}];
    
    //  AnalysysAgent SDK配置信息
    AnalysysConfig.appKey = @"heatmaptest0916";
    AnalysysConfig.channel = @"App Store";
    AnalysysConfig.autoProfile = YES;
    AnalysysConfig.autoTrackCrash = NO;
    AnalysysConfig.autoInstallation = YES;
    AnalysysConfig.autoTrackDeviceId = YES;
    AnalysysConfig.encryptType = AnalysysEncryptAESCBC128;
    //    AnalysysConfig.allowTimeCheck = YES;
    //    AnalysysConfig.maxDiffTimeInterval = 5 * 60;
    
    //  设置证书校验模式(仅https)，默认：ANSSSLPinningModeNone
    ANSSecurityPolicy *securityPolicy = [ANSSecurityPolicy policyWithPinningMode:ANSSSLPinningModeCertificate];
    //  是否支持非法的证书（如：自签名证书）， 默认：NO
    securityPolicy.allowInvalidCertificates = NO;
    //  是否验证证书域名是否匹配，默认：YES
    securityPolicy.validatesDomainName = YES;
    //  本地证书路径配置
    //securityPolicy.pinnedCertificates = [ANSSecurityPolicy certificatesInBundle:[NSBundle mainBundle]];
    //  配置证书策略
    AnalysysConfig.securityPolicy = securityPolicy;

    // 使用配置信息初始化SDK
    [AnalysysAgent startWithConfig:AnalysysConfig];
    
    //    NSLog(@"distinctid:%@", [AnalysysAgent getDistinctId]);
    
#if DEBUG
    [AnalysysAgent setDebugMode:AnalysysDebugButTrack];
#else
    [AnalysysAgent setDebugMode:AnalysysDebugOff];
#endif
    
    [AnalysysAgent setUploadURL:@"http://192.168.220.105:8089"];
    
#if DEBUG
    [AnalysysAgent setVisitorDebugURL:@"ws://192.168.220.105:9091"];
#endif
    [AnalysysAgent setVisitorConfigURL:@"http://192.168.220.105:8089"];
    
    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
    NSLog(@"The code execution time %f ms", linkTime *1000.0);
}

/// 广告标识：iOS 14之后需要请求用户
/// 1. 引入AppTrackingTransparency.framework
/// 2. 在Info.plist中增加隐私配置Privacy - Tracking Usage Description
/// 3. 请求用户
- (void)requestAdvertisingIdentifier {
//    if (@available(iOS 14, *)) {
//        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
//            NSLog(@"广告标识符请求用户选择结果-------%lu", (unsigned long)status);
//        }];
//    } else {
//        // Fallback on earlier versions
//    }
//
//    NSString *idfa = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
//    NSLog(@"idfa----%@", idfa);
}

#pragma mark - App跳转
//  测试网页
//  https://uc.analysys.cn/huaxiang/fangzhouBVisual/web/upApp.html?from=singlemessage&isappinstalled=0

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

#pragma mark - other

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.window endEditing:YES];
}

@end
