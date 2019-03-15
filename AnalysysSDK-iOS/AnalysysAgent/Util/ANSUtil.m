//
//  ANSUtil.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/23.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSUtil.h"

#import "AnalysysAgent.h"
#import "ANSConst.h"
#import "ANSStrategyManager.h"
#import "ANSGzip.h"
#import "ANSModuleProcessing.h"

@implementation ANSUtil

+ (long long)currentTimeMillisecond {
    NSDate *date = [NSDate date];
    NSTimeInterval nowtime = [date timeIntervalSince1970]*1000;
    long long timeLongValue = [[NSNumber numberWithDouble:nowtime] longLongValue];
    return timeLongValue;
}

+ (UIViewController *)rootViewController {
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (!window) {
        window = [UIApplication sharedApplication].delegate.window;
    }
    if (window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController *result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    if ([result isKindOfClass:[UITabBarController class]]) {
        return result;
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)result topViewController];
    }
    return result;
}

+ (UIViewController *)topViewController {
    __block UIViewController *currentVC = nil;
    if ([NSThread isMainThread]) {
        @try {
            UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
            if (rootViewController != nil) {
                currentVC = [self currentVCWithRoot:rootViewController];
            }
        } @catch (NSException *exception) {
            NSLog(@"error: %@", exception.description);
        }
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            currentVC = [ANSUtil topViewController];
        });
    }
    return currentVC;
}

+ (UIViewController *)currentVCWithRoot:(UIViewController *)rootVC {
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        rootVC = [self currentVCWithRoot:rootVC.presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        currentVC = [self currentVCWithRoot:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        currentVC = [self currentVCWithRoot:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        if ([rootVC respondsToSelector:NSSelectorFromString(@"contentViewController")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            UIViewController *tempViewController = [rootVC performSelector:NSSelectorFromString(@"contentViewController")];
#pragma clang diagnostic pop
            if (tempViewController) {
                currentVC = [self currentVCWithRoot:tempViewController];
            }
        } else {
            currentVC = rootVC;
        }
    }
    return currentVC;
}

+ (NSDictionary *)httpHeaderInfo {
    NSMutableDictionary *httpHeader = [NSMutableDictionary dictionary];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *policyVersion = [ANSStrategyManager sharedManager].serverStrategy.hashCode;
    NSString *spv = [NSString stringWithFormat:@"iOS|%@|%@|%@|%@", AnalysysConfig.appKey, ANSSDKVersion, policyVersion, appVersion];
    NSData *spvData = [spv dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Spv = [spvData base64EncodedStringWithOptions:0];
    httpHeader[@"spv"] = base64Spv;
    
    //  额外header
    switch (AnalysysConfig.encryptType) {
        case AnalysysEncryptAES:
        {
            NSDictionary *extroHeader = [[ANSModuleProcessing sharedManager] extroHeaderInfo];
            if (extroHeader) {
                [httpHeader addEntriesFromDictionary:extroHeader];
            }
        }
            break;
        default:
            break;
    }
    return [httpHeader copy];
}

+ (NSString *)processUploadBody:(NSString *)bodyJson param:(NSDictionary *)param {
    NSString *uploadString = bodyJson;
    switch (AnalysysConfig.encryptType) {
        case AnalysysEncryptAES:
            uploadString = [[ANSModuleProcessing sharedManager] encryptJsonString:bodyJson config:AnalysysConfig param:param];
            break;
        default:
            break;
    }
    return [self zipAndBase64WithString:uploadString];
}

/** 数据 压缩 -> base64 */
+ (NSString *)zipAndBase64WithString:(NSString *)jsonStr {
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *zipData = [ANSGzip gzipData:jsonData];
    return [zipData base64EncodedStringWithOptions:0];
}

@end
