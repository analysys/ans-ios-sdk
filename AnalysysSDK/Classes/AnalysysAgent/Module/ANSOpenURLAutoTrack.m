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
#import "ANSFileManager.h"
#import "NSThread+ANSHelper.h"
#import "ANSConst+private.h"

@implementation ANSOpenURLAutoTrack

+ (void)autoTrack {
    [NSThread ansRunOnMainThread:^{
        [self excuteSwizzingOpenURL];
    }];
}

#pragma mark - openURL参数解析

+ (void)excuteSwizzingOpenURL {
    SEL selector = nil;
    Class cls = [[UIApplication sharedApplication].delegate class];
    
    if (class_getInstanceMethod(cls, NSSelectorFromString(@"application:openURL:options:"))) {
        selector = NSSelectorFromString((@"application:openURL:options:"));
        [ANSSwizzler swizzleSelector:selector
                             onClass:cls
                           withBlock:^(id view, SEL command, UIApplication *application, NSURL *url, NSDictionary *options) {
                               [self parseOpenURL:url];
                           }
                               named:@"ANSOpenURLOptions"];
    }
    if (class_getInstanceMethod(cls, NSSelectorFromString(@"application:openURL:sourceApplication:annotation:"))) {
        selector = NSSelectorFromString(@"application:openURL:sourceApplication:annotation:");
        [ANSSwizzler swizzleSelector:selector
                             onClass:cls
                           withBlock:^(id view, SEL command, UIApplication *application, NSURL *url, NSString *sourceApplication, id annotation) {
                               [self parseOpenURL:url];
                           }
                               named:@"ANSOpenURLSourceApplication"];
    }
    if (class_getInstanceMethod(cls, NSSelectorFromString(@"application:handleOpenURL:"))) {
        selector = NSSelectorFromString(@"application:handleOpenURL:");
        [ANSSwizzler swizzleSelector:selector
                             onClass:cls
                           withBlock:^(id view, SEL command, UIApplication *application, NSURL *url) {
                               [self parseOpenURL:url];
                           }
                               named:@"ANSHandleOpenURL"];
    }
    if (class_getInstanceMethod(cls, NSSelectorFromString(@"application:continueUserActivity:restorationHandler:"))) {
        selector = NSSelectorFromString(@"application:continueUserActivity:restorationHandler:");
        if (@available(iOS 8.0, *)) {
            [ANSSwizzler swizzleSelector:selector
                                 onClass:cls
                               withBlock:^(id view, SEL command, UIApplication *application, NSUserActivity *userActivity, id restorationHandler) {
                                   [self parseOpenURL:userActivity.webpageURL];
                               }
                                   named:@"ANSContinueUserActivity"];
        }
    }
}

/** 解析三方调起url */
+ (void)parseOpenURL:(NSURL *)url {
    if (url == nil || url.absoluteString.length == 0) {
        return;
    }
    NSDictionary *queryParameters = [self parameterWithURL:url];
    NSDictionary *utm = [self utmParametersFromWakeDictionary:queryParameters];
    if (utm) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ANSAppWakedUpNotification" object:nil];
        [self saveUtmParameters:utm];
    }
}

+ (NSDictionary *)parameterWithURL:(NSURL *)url {
    NSDictionary *queryParameters;
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:url.absoluteString];
    if (@available(iOS 8.0, *)) {
        NSMutableDictionary *query = [NSMutableDictionary dictionary];
        [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [query setValue:obj.value forKey:obj.name];
        }];
        queryParameters = [NSDictionary dictionaryWithDictionary:query];
    } else {
        NSArray *queryArray = [self queryArrayWithURL:url];
        queryParameters = [self dictionaryWithURLQueryArray:queryArray];
    }
    return queryParameters;
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
                [parameters setValue:value forKey:key];
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
    NSArray * allKeys = parameters.allKeys;
    if ([allKeys containsObject:@"utm_source"] &&
        [allKeys containsObject:@"utm_medium"] &&
        [allKeys containsObject:@"utm_campaign"]) {
        NSMutableDictionary *utmParameters = [NSMutableDictionary dictionary];
        [utmParameters setValue:parameters[@"utm_campaign"] forKey:ANSUtmCampaign];
        [utmParameters setValue:parameters[@"utm_medium"] forKey:ANSUtmMedium];
        [utmParameters setValue:parameters[@"utm_source"] forKey:ANSUtmSource];
        [utmParameters setValue:parameters[@"campaign_id"] forKey:ANSUtmCampaignId];
        [utmParameters setValue:parameters[@"utm_content"] forKey:ANSUtmContent];
        [utmParameters setValue:parameters[@"utm_term"] forKey:ANSUtmTerm];

        return [utmParameters copy];
    }
    if ([allKeys containsObject:@"hmsr"] &&
        [allKeys containsObject:@"hmpl"] &&
        [allKeys containsObject:@"hmcu"]) {
        NSMutableDictionary *utmParameters = [NSMutableDictionary dictionary];
        [utmParameters setValue:parameters[@"hmcu"] forKey:ANSUtmCampaign];
        [utmParameters setValue:parameters[@"hmpl"] forKey:ANSUtmMedium];
        [utmParameters setValue:parameters[@"hmsr"] forKey:ANSUtmSource];
        [utmParameters setValue:parameters[@"hmci"] forKey:ANSUtmContent];
        [utmParameters setValue:parameters[@"hmkw"] forKey:ANSUtmTerm];
        return [utmParameters copy];
    }
    return nil;
}

#pragma mark - 数据存储

static NSString *const AnalysysUtm = @"AnalysysUtm";
/** 存储UTM参数 */
+ (void)saveUtmParameters:(nullable NSDictionary *)utmParameters {
    [ANSFileManager saveUserDefaultWithKey:AnalysysUtm value:utmParameters];
}

/** 获取UTM参数 */
+ (NSDictionary *)utmParameters {
    return [[ANSFileManager userDefaultValueWithKey:AnalysysUtm] copy];
}



@end
