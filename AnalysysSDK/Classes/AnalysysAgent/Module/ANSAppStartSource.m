//
//  ANSAppStartSource.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/10/25.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSAppStartSource.h"

#import "ANSSwizzler.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

//  App启动方式
static NSString *const startIcon = @"icon"; // 点击图标启动
static NSString *const startNotification = @"msg"; // 点击通知
static NSString *const startOpenURL = @"url"; // 唤醒
static NSString *const start3D = @"3D"; //  3D touch
static NSString *const startOther = @"0"; //  其他，如home键切换、后台热启动

@interface ANSAppStartSource ()

@property (nonatomic, copy) NSString *appStartType; //  App 启动方式
@property (nonatomic, assign) BOOL isUsedStartMonitor;  // 是否开启该功能

@end


@implementation ANSAppStartSource 

+ (instancetype)sharedManager {
    static id singleInstance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        singleInstance = [[self alloc] init] ;
    });
    return singleInstance;
}

- (void)startMonitorAppDelegate:(id<UIApplicationDelegate>)delegate launchOptions:(NSDictionary *)launchOptions {
    
    self.isUsedStartMonitor = YES;
    
    //  通过launchOptions判断启动方式
    [self appStartWithLaunchOptions:launchOptions];
    
    @try {
        [self track3DTouchWithAppDelegate:delegate];
        
        [self trackOpenUrlWithAppDelegate:delegate];
        
        [self trackRemoteNotificationWithAppDelegate:delegate];
    } @catch (NSException *exception) {
        NSLog(@"********** [Analysys] [Debug] %@ **********", exception.description);
    }
}

- (NSString *)getStartSource {
    if (!self.isUsedStartMonitor) {
        return nil;
    }
    NSString *startType = self.appStartType;
    if (startType.length == 0) {
        startType = startOther;
    }
    self.appStartType = nil;
    return startType;
}

#pragma mark *** 监测App启动方法 ***

/** 默认启动 */
- (void)appStartWithLaunchOptions:(NSDictionary *)launchOptions {
    if (!launchOptions) {
        self.appStartType = startIcon;
    } else {
        NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        if (url) {
            self.appStartType = startOpenURL;
            return;
        }
        if (@available(iOS 8.0, *)) {
            NSDictionary *userActivity = [launchOptions objectForKey:UIApplicationLaunchOptionsUserActivityDictionaryKey];
            if (userActivity) {
                self.appStartType = startOpenURL;
                return;
            }
        }
        NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (remoteNotification) {
            self.appStartType = startNotification;
            return;
        }
        if (@available(iOS 9.0, *)) {
            id touch3D = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
            if (touch3D) {
                self.appStartType = start3D;
                return;
            }
        }
    }
}

/** 3D touch启动 */
- (void)track3DTouchWithAppDelegate:(id<UIApplicationDelegate>)delegate {
    if (@available(iOS 9.0, *)) {
        SEL touchSel = @selector(application:performActionForShortcutItem:completionHandler:);
        if ([delegate respondsToSelector:touchSel]) {
            typedef void (^handler)(BOOL);
            [ANSSwizzler swizzleSelector:touchSel
                                 onClass:[delegate class]
                               withBlock:^(id view, SEL command, UIApplication *application, UIApplicationShortcutItem *shortcutItem, handler completionHandler){
                self->_appStartType = start3D;
            } named:@"ANSStartSourcePerformActionForShortcutItem"];
        }
    }
}

/** App吊起启动 */
- (void)trackOpenUrlWithAppDelegate:(id<UIApplicationDelegate>)delegate {
    //  App吊起
    SEL openUrlSel = @selector(application:handleOpenURL:);
    if ([delegate respondsToSelector:@selector(application:handleOpenURL:)]) {
        [ANSSwizzler swizzleSelector:openUrlSel
                             onClass:[delegate class]
                           withBlock:^(id view, SEL command, UIApplication *application, NSURL *url){
            self->_appStartType = startOpenURL;
        } named:@"ANStartSourceSHandleOpenURL"];
    }
    
    SEL openURLOptionSel = @selector(application:openURL:options:);
    if ([delegate respondsToSelector:openURLOptionSel]) {
        [ANSSwizzler swizzleSelector:openURLOptionSel
                             onClass:[delegate class]
                           withBlock:^(id view, SEL command, UIApplication *application, NSURL *url, NSDictionary *options){
            self->_appStartType = startOpenURL;
        } named:@"ANSStartSourceOpenURLOptions"];
    }
    
    SEL openURLSourceSel = @selector(application:openURL:sourceApplication:annotation:);
    if ([delegate respondsToSelector:openURLSourceSel]) {
        [ANSSwizzler swizzleSelector:openURLSourceSel
                             onClass:[delegate class]
                           withBlock:^(id view, SEL command, UIApplication *application, NSURL *url, NSString *sourceApplication, id annotation){
            self->_appStartType = startOpenURL;
        } named:@"ANSStartSourceOpenURLsourceApplication"];
    }
    
    //  Universal Links
    SEL userActivitySel = @selector(application:continueUserActivity:restorationHandler:);
    if ([delegate respondsToSelector:userActivitySel]) {
        typedef void (^handler)(NSArray *);
        if (@available(iOS 8.0, *)) {
            [ANSSwizzler swizzleSelector:userActivitySel
                                 onClass:[delegate class]
                               withBlock:^(id view, SEL command, UIApplication *application, NSUserActivity *userActivity,handler restorableObjects){
                self->_appStartType = startOpenURL;
            } named:@"ANSStartSourceUserActivity"];
        }
    }
}

/** 通知启动 */
- (void)trackRemoteNotificationWithAppDelegate:(id<UIApplicationDelegate>)delegate {
    //  iOS 10 ~
    if (@available(iOS 10.0, *)) {
        SEL selector = @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
        if ([delegate respondsToSelector:selector]) {
            typedef void (^completionHandler)(void);
            [ANSSwizzler swizzleSelector:selector
                                 onClass:[delegate class]
                               withBlock:^(id view, SEL command, UNUserNotificationCenter *center, UNNotificationResponse *response, completionHandler completionHandler) {
                self->_appStartType = startNotification;
            } named:@"ANSStartSourceReceiveNotificationResponse"];
            
        }
    } else {
        // < iOS7.0
        SEL remote7Sel = @selector(application:didReceiveRemoteNotification:);
        if ([delegate respondsToSelector:remote7Sel]) {
            [ANSSwizzler swizzleSelector:remote7Sel
                                 onClass:[delegate class]
                               withBlock:^(id view, SEL command, UIApplication *application, NSDictionary *userInfo){
                self->_appStartType = startNotification;
            } named:@"ANSStartSourceReceiveRemoteNotification"];
        }
        
        //  iOS 7.0 ~ iOS 9.0
        SEL remote9Sel = @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:);
        if ([delegate respondsToSelector:remote9Sel]) {
            typedef void (^handler)(UIBackgroundFetchResult);
            [ANSSwizzler swizzleSelector:remote9Sel
                                 onClass:[delegate class]
                               withBlock:^(id view, SEL command, UIApplication *application, NSDictionary *userInfo, handler completionHandler){
                self->_appStartType = startNotification;
            } named:@"ANSStartSourceRemoteFetchCompletionHandler"];
        }
    }
}


@end
