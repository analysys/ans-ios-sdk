//
//  AnalysysPush.h
//  AnalysysAgent
//
//  Created by analysys on 2018/5/31.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "AnalysysPush.h"
#import "ANSJsonUtil.h"
#import "AnalysysLogger.h"
#import "ANSUtil.h"
#import "ANSControllerUtils.h"
#import "ANSConst+private.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <SafariServices/SafariServices.h>
#endif

#import <objc/runtime.h>

static NSString * const ANSCampaignKey = @"EGPUSH_CINFO";//  易观推送标识

@implementation AnalysysPush {
    BOOL _isContainAnsPush;//   易观活动标识
    id _ansPushInfo;//  活动信息
}

+ (instancetype)shareInstance {
    static AnalysysPush *instance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[AnalysysPush alloc] init] ;
    });
    return instance;
}

#pragma mark - public method

/** 解析推送信息 */
+ (NSDictionary *)parseAnsPushInfo:(id)userInfo {
    return [[AnalysysPush shareInstance] parseAnalysysPushInfo:userInfo];
}

/** 拼接context */
+ (NSDictionary *)spliceContextWithPushInfo:(NSDictionary *)pushInfo {
    NSMutableDictionary *context = [NSMutableDictionary dictionary];
    [context setValue:[NSString stringWithFormat:@"%@",pushInfo[@"campaign_id"]] forKey:ANSUtmCampaignId];
    [context setValue:pushInfo[@"utm_campaign"] forKey:ANSUtmCampaign];
    [context setValue:pushInfo[@"utm_medium"] forKey:ANSUtmMedium];
    [context setValue:pushInfo[@"utm_source"] forKey:ANSUtmSource];
    [context setValue:pushInfo[@"utm_content"] forKey:ANSUtmContent];
    [context setValue:pushInfo[@"utm_term"] forKey:ANSUtmTerm];
    [context setValue:pushInfo[@"ACTIONTYPE"] forKey:ANSUtmActionType];
    [context setValue:pushInfo[@"ACTION"] forKey:ANSUtmAction];
    [context setValue:pushInfo[@"CPD"] forKey:ANSUtmCpd];
    return context;
}

/**
 点击活动通知
 - actionType：1 打开app
 - actionType：2 跳转指定页面
 - actionType：3 打开URL
 - actionType：4 自定义操作 返回活动信息
 @param pushInfo 推送信息
 */
+ (void)clickAnsPushInfo:(NSDictionary *)pushInfo {
    NSString *actionType = [NSString stringWithFormat:@"%@",pushInfo[@"ACTIONTYPE"]];
    NSString *actionStr = pushInfo[@"ACTION"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([actionType isEqualToString:@"2"] && actionStr.length > 0) {
            [[AnalysysPush shareInstance] pushUserViewControllerWithActivity:pushInfo];
        } else if ([actionType isEqualToString:@"3"] && actionStr.length > 0) {
            [[AnalysysPush shareInstance] openUrlStr:actionStr];
        }
    });
}

#pragma mark - private method

- (NSDictionary *)parseAnalysysPushInfo:(id)userInfo {
    _isContainAnsPush = NO;
    _ansPushInfo = nil;
    @try {
        if ([userInfo isKindOfClass:[NSString class]]) {
            NSString *pushStr = (NSString *)userInfo;
            if ([pushStr rangeOfString:ANSCampaignKey].location != NSNotFound) {
                NSDictionary *pushInfo = [ANSJsonUtil convertToMapWithString:pushStr];
                if (pushInfo) {
                    [self parseCampaignWithPushInfo:pushInfo];
                }
            }
        } else if ([userInfo isKindOfClass:[NSDictionary class]]) {
            NSDictionary *remotePushInfo = (NSDictionary *)userInfo;
            [self parseCampaignWithPushInfo:remotePushInfo];
        }
        
        if ([_ansPushInfo isKindOfClass:[NSString class]]) {
            _ansPushInfo = [ANSJsonUtil convertToMapWithString:_ansPushInfo];
        }
        return _ansPushInfo;
    } @catch (NSException *exception) {
        return nil;
    }
}

/** 判断推送信息中是否包含活动信息 */
- (id)parseCampaignWithPushInfo:(NSDictionary *)userInfo {
    for (id key in userInfo.allKeys) {
        if (_isContainAnsPush) {
            break;
        }
        if ([key isKindOfClass:[NSString class]]) {
            if ([key isEqualToString:ANSCampaignKey]) {
                _ansPushInfo = userInfo[key];
                _isContainAnsPush = YES;
                break;
            }
            [self checkSubInfo:userInfo[key]];
        }
    }
    return _ansPushInfo;
}

/** 检查内层value */
- (void)checkSubInfo:(id)subInfo {
    if ([subInfo isKindOfClass:[NSDictionary class]]) {
        [self parseCampaignWithPushInfo:subInfo];
    } else if ([subInfo isKindOfClass:[NSString class]]) {
        NSDictionary *subInfoDic = [ANSJsonUtil convertToMapWithString:subInfo];
        if (subInfoDic) {
            [self parseCampaignWithPushInfo:subInfoDic];
        }
    }
}

/** 打开指定链接 */
- (void)openUrlStr:(NSString *)urlStr {
    NSURL *openURL = [NSURL URLWithString:urlStr];
    if ([[UIApplication sharedApplication] canOpenURL:openURL]) {
        if (@available(iOS 9.0, *)) {
            SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:openURL];
            [[ANSUtil currentKeyWindow].rootViewController presentViewController:safari animated:YES completion:nil];
        } else {
            [[UIApplication sharedApplication] openURL:openURL];
        }
    } else {
        ANSBriefWarning(@"%@",[NSString stringWithFormat:@"您所填写的活动链接不合法->%@",urlStr]);
    }
}

/** 打开指定页面 */
- (void)pushUserViewControllerWithActivity:(NSDictionary *)campaignInfo {
    NSString *actionStr = campaignInfo[@"ACTION"];
    NSDictionary *property = campaignInfo[@"CPD"];
    const char *className = [actionStr cStringUsingEncoding:NSASCIIStringEncoding];
    
    Class nextPageClass = objc_getClass(className);
    if (!nextPageClass) {
        ANSBriefWarning(@"%@",[NSString stringWithFormat:@"您所填写的活动页面不存在->%@",actionStr]);
        return;
    }
    UIViewController *nextVC;
    @try {
        NSString *storyBoardName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIMainStoryboardFile"];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
        nextVC = [sb instantiateViewControllerWithIdentifier:NSStringFromClass(nextPageClass)];
    } @catch (NSException *exception) {
        NSString *xibPath = [[NSBundle mainBundle] pathForResource:NSStringFromClass(nextPageClass) ofType:@"nib"];
        if (xibPath) {
            nextVC = [[nextPageClass alloc] initWithNibName:NSStringFromClass(nextPageClass) bundle:nil];
        } else {
            nextVC = [[nextPageClass alloc] init];
        }
    }
    //  页面属性赋值
    if ([property isKindOfClass:[NSDictionary class]]) {
        [property enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([self isExistPropertyInObject:nextVC propertyName:key]) {
                [nextVC setValue:obj forKey:key];
            }
        }];
    }
    
    [self pushViewController:nextVC];
}

/** 跳转页面 */
- (void)pushViewController:(UIViewController *)nextVC {
    @try {
        id rootVC = [ANSControllerUtils rootViewController];
        
        if ([rootVC isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabVC = (UITabBarController *)rootVC;
            id selectVC = tabVC.selectedViewController;
            if ([selectVC isKindOfClass:[UINavigationController class]]) {
                UINavigationController *rootNC = (UINavigationController *)selectVC;
                nextVC.hidesBottomBarWhenPushed = YES;
                [rootNC pushViewController:nextVC animated:YES];
            } else {
                [(UIViewController *)rootVC presentViewController:nextVC animated:NO completion:nil];
            }
        } else if ([rootVC isKindOfClass:[UINavigationController class]]) {
            UINavigationController *rootNC = (UINavigationController *)rootVC;
            rootNC.hidesBottomBarWhenPushed = YES;
            [rootNC pushViewController:nextVC animated:YES];
        } else {
            //  适配RDVTabBarController
            SEL sel = NSSelectorFromString(@"selectedViewController");
            if ([rootVC respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                UIViewController *tabNavi = [rootVC performSelector:sel];
#pragma clang diagnostic pop
                if ([tabNavi isKindOfClass:[UINavigationController class]]) {
                    tabNavi.hidesBottomBarWhenPushed = YES;
                    [(UINavigationController*)tabNavi pushViewController:nextVC animated:YES];
                }
            } else {
                [rootVC presentViewController:nextVC animated:NO completion:nil];
            }
        }
    } @catch (NSException *exception) {
        
    }
}

/** 检测变量是否存在 */
- (BOOL)isExistPropertyInObject:(id)instance propertyName:(NSString *)verifyPropertyName {
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([instance class], &outCount);
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if ([propertyName isEqualToString:verifyPropertyName]) {
            free(properties);
            return YES;
        }
    }
    free(properties);
    
    return NO;
}

@end
