//
//  ANSOpenURLAutoTrack.m
//  AnalysysAgent
//
//  Created by SoDo on 2018/12/6.
//  Copyright © 2018 analysys. All rights reserved.
//

#import "ANSOpenURLAutoTrack.h"

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "ANSSwizzler.h"
#import "ANSSession.h"

@implementation ANSOpenURLAutoTrack

+ (void)autoTrack {
    if ([NSThread isMainThread]) {
        SEL selector = nil;
        Class cls = [[UIApplication sharedApplication].delegate class];
        
        if (class_getInstanceMethod(cls, NSSelectorFromString(@"application:openURL:options:"))) {
            selector = NSSelectorFromString((@"application:openURL:options:"));
            [ANSSwizzler swizzleSelector:selector
                                 onClass:cls
                               withBlock:^(id view, SEL command, UIApplication *application, NSURL *url, NSDictionary *options) {
                                   [self parseOpenURL:url];
                               }
                                   named:@"ans_openURL_options"];
        } else if (class_getInstanceMethod(cls, NSSelectorFromString(@"application:openURL:sourceApplication:annotation:"))) {
            selector = NSSelectorFromString(@"application:openURL:sourceApplication:annotation:");
            [ANSSwizzler swizzleSelector:selector
                                 onClass:cls
                               withBlock:^(id view, SEL command, UIApplication *application, NSURL *url, NSString *sourceApplication, id annotation) {
                                   [self parseOpenURL:url];
                               }
                                   named:@"ans_openURL_sourceApplication"];
        } else if (class_getInstanceMethod(cls, NSSelectorFromString(@"application:handleOpenURL:"))) {
            selector = NSSelectorFromString(@"application:handleOpenURL:");
            [ANSSwizzler swizzleSelector:selector
                                 onClass:cls
                               withBlock:^(id view, SEL command, UIApplication *application, NSURL *url) {
                                   [self parseOpenURL:url];
                               }
                                   named:@"ans_handleOpenURL"];
        }
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self autoTrack];
        });
    }
}

#pragma mark *** openURL参数解析 ***

/** 解析三方吊起url */
+ (void)parseOpenURL:(NSURL *)url {
    NSArray *queryArray = [self queryArrayWithURL:url];
    NSDictionary *queryParameters = [self dictionaryWithURLQueryArray:queryArray];
    NSDictionary *utm = [self utmParametersFromWakeDictionary:queryParameters];
    if (utm) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ANSAppWakedUpNotification" object:nil];
        [self saveUtmParameters:utm];
    }
}

/** 获取URL/Scheme参数 数组 */
+ (NSArray *)queryArrayWithURL:(NSURL *)url {
    NSString *queryStr;
    if (@available(iOS 9.0, *)) {
        queryStr = [url.query stringByRemovingPercentEncoding];
    } else {
        queryStr = [url.query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if (queryStr == nil) {
        // scheme AnalysysApp://page=HomePage&id=1
        NSString *urlStr = [[NSString stringWithFormat:@"%@",url] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSRange sRange = [urlStr rangeOfString:@"://"];
        if (sRange.location != NSNotFound) {
            queryStr = [urlStr substringFromIndex:sRange.location + sRange.length];
        }
    }
    if (queryStr == nil) {
        return nil;
    }
    return [queryStr componentsSeparatedByString:@"&"];
}

/** 将URL/Scheme参数数组 转换 为字典 */
+ (NSDictionary *)dictionaryWithURLQueryArray:(NSArray *)queryArray {
    @try {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        for (NSString *paraStr in queryArray) {
            //  第一个'='后为value值
            NSRange range = [paraStr rangeOfString:@"="];
            if (range.location != NSNotFound) {
                NSString *key = [paraStr substringToIndex:range.location];
                NSString *value = [paraStr substringFromIndex:range.location+range.length];
                parameters[key] = value;
            }
        }
        return [parameters copy];
    } @catch (NSException *exception) {
        return nil;
    }
}

/** 解析App唤醒参数 */
+ (NSDictionary *)utmParametersFromWakeDictionary:(NSDictionary *)parameters {
    if (!parameters) {
        return nil;
    }
    if ([parameters.allKeys containsObject:@"utm_source"] &&
        [parameters.allKeys containsObject:@"utm_medium"] &&
        [parameters.allKeys containsObject:@"utm_campaign"]) {
        NSMutableDictionary *utmParameters = [NSMutableDictionary dictionary];
        utmParameters[@"$utm_campaign"] = parameters[@"utm_campaign"];
        utmParameters[@"$utm_medium"] = parameters[@"utm_medium"];
        utmParameters[@"$utm_source"] = parameters[@"utm_source"];
        utmParameters[@"$utm_campaign_id"] = parameters[@"campaign_id"];
        utmParameters[@"$utm_content"] = parameters[@"utm_content"];
        utmParameters[@"$utm_term"] = parameters[@"utm_term"];
        return [utmParameters copy];
    }
    if ([parameters.allKeys containsObject:@"hmsr"] &&
        [parameters.allKeys containsObject:@"hmpl"] &&
        [parameters.allKeys containsObject:@"hmcu"]) {
        NSMutableDictionary *utmParameters = [NSMutableDictionary dictionary];
        utmParameters[@"$utm_campaign"] = parameters[@"hmcu"];
        utmParameters[@"$utm_medium"] = parameters[@"hmpl"];
        utmParameters[@"$utm_source"] = parameters[@"hmsr"];
        utmParameters[@"$utm_content"] = parameters[@"hmci"];
        utmParameters[@"$utm_term"] = parameters[@"hmkw"];
        return [utmParameters copy];
    }
    return nil;
}

#pragma mark *** 数据存储 ***

/** 存储UTM参数 */
+ (void)saveUtmParameters:(nullable NSDictionary *)utmParameters {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:utmParameters forKey:@"AnalysysUtm"];
    [defaults synchronize];
}

/** 获取UTM参数 */
+ (NSDictionary *)utmParameters {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:@"AnalysysUtm"];
}



@end
