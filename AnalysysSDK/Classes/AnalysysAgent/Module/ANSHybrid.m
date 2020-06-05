//
//  ANSHybrid.m
//  AnalysysAgent
//
//  Created by SoDo on 2018/7/23.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "ANSHybrid.h"

#import <UIKit/UIKit.h>
#import "AnalysysAgent.h"
#import "AnalysysLogger.h"
#import "ANSJsonUtil.h"
#import "ANSFileManager.h"
#import "ANSLock.h"

#import "AnalysysSDK.h"
#import "ANSDataCheckLog.h"
#import "ANSDataCheckRouter.h"

static NSString *ANSHybridId = @" AnalysysAgent/Hybrid";
static NSString *ANSUserAgentId = @"UserAgent";

@interface ANSHybrid()

@property (nonatomic, strong) ANSJsonUtil *jsonUtil;

@end


@implementation ANSHybrid

+ (instancetype)shareInstance {
    static id singleInstance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        if (!singleInstance) {
            singleInstance = [[self alloc] init] ;
        }
    });
    return singleInstance;
}

#pragma mark - Interface

+ (BOOL)excuteRequest:(NSURLRequest *)request webView:(id)webView {
    
    ANSHybrid *hybridInstance = [ANSHybrid shareInstance];
    //  添加UA
    [hybridInstance addUserAgent:webView];
    
    NSString *URLString = [request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *hybridId = @"analysysagent:";
    if ([URLString hasPrefix:hybridId]) {
        NSString *str = [URLString substringFromIndex:hybridId.length];
        NSDictionary *dic = [ANSJsonUtil convertToMapWithString:str];
        if (!dic) {
            return NO;
        }
        
        NSString *funcName = dic[@"functionName"];
        NSArray *funcParam = dic[@"functionParams"];
        NSString *funcCallBack = dic[@"callbackFunName"];
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:",funcName]);
        if (funcCallBack.length) {
            selector = NSSelectorFromString([NSString stringWithFormat:@"%@:webView:",funcName]);
        }
        
        if ([hybridInstance respondsToSelector:selector]) {
            if (funcCallBack.length == 0) {
                ((void (*)(id, SEL, NSArray*))[hybridInstance methodForSelector:selector])(hybridInstance, selector, funcParam);
            } else {
                NSMutableArray *desArray = [NSMutableArray arrayWithArray:funcParam];
                [desArray addObject:funcCallBack];
                ((void (*)(id, SEL, NSMutableArray*, id))[hybridInstance methodForSelector:selector])(hybridInstance, selector, desArray, webView);
            }
        } else {
            ANSBriefWarning(@"Hybrid: Did not match to the js method: %@.",funcName);
        }
        return YES;
    }
    
    return NO;
}

/** 删除自定义UA */
+ (void)resetHybridModel {
    dispatch_block_t block = ^(){
        NSString *ansUserAgent = [ANSFileManager userDefaultValueWithKey:ANSUserAgentId];
        if (ansUserAgent) {
            NSString *userAgent = [ansUserAgent stringByReplacingOccurrencesOfString:ANSHybridId withString:@""];
            NSDictionary *userAgentDict = @{ANSUserAgentId: userAgent};
            ANSUserDefaultsLock();
            [[NSUserDefaults standardUserDefaults] registerDefaults:userAgentDict];
            ANSUserDefaultsUnlock();
        }
    };
    if ([[NSThread currentThread] isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

#pragma mark - Pirvate Method

/** 设置webview agent标识，供hybrid使用 */
- (void)addUserAgent:(id)webView {
    dispatch_block_t block = ^(){
        NSString *ansUserAgent = [ANSFileManager userDefaultValueWithKey:ANSUserAgentId];
        if (ansUserAgent == nil || [ansUserAgent rangeOfString:ANSHybridId].location == NSNotFound) {
            [self WKWebView:webView uaBlock:^(NSString *userAgent) {
                [self setUserAgent:userAgent WKWebView:webView];
            }];
        }
    };
    if ([[NSThread currentThread] isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

//  获取WKWebView的UA
- (void)WKWebView:(id)webView uaBlock:(void(^)(NSString *))uaBlock {
    @try {
        if ([webView isKindOfClass:NSClassFromString(@"WKWebView")]) {
            SEL evaluateSelector = NSSelectorFromString(@"evaluateJavaScript:completionHandler:");
            if (evaluateSelector) {
                typedef void(^CompletionBlock)(id, NSError *);
                CompletionBlock completionHandler = ^(id response, NSError *error) {
                    //                NSLog(@"response:%@ error:%@",response, error.description);
                    if (response && [response isKindOfClass:NSString.class]) {
                        uaBlock(response);
                    }
                };
                IMP evaluateImp = [webView methodForSelector:evaluateSelector];
                void *(*func)(id, SEL, NSString*, CompletionBlock) = (void *(*)(id, SEL, NSString *, CompletionBlock))evaluateImp;
                func(webView, evaluateSelector, @"navigator.userAgent", completionHandler);
            }
        }
    } @catch (NSException *exception) {
        
    }
}

/** 更新本地及WKWebView的UA */
- (void)setUserAgent:(NSString *)userAgent WKWebView:(id)webView {
    userAgent = [userAgent stringByAppendingString:ANSHybridId];
    NSDictionary *userAgentDict = @{ANSUserAgentId: userAgent};
    
    ANSUserDefaultsLock();
    [[NSUserDefaults standardUserDefaults] registerDefaults:userAgentDict];
    ANSUserDefaultsUnlock();
    
    //  WKWebView 需要设置 setCustomUserAgent:
    SEL selector = NSSelectorFromString(@"setCustomUserAgent:");
    if ([webView respondsToSelector:selector]) {
        IMP imp = [webView methodForSelector:selector];
        void *(*func)(id, SEL, NSString*) = (void *)imp;
        func(webView, selector, userAgent);
    }
}

/** 字典转json */
-(NSString *)jsonStringWithobject:(id)object {
    @try {
        id converObject = [ANSJsonUtil convertToJsonObjectWithObject:object];
        if ([converObject isKindOfClass:[NSNumber class]] ||
            [converObject isKindOfClass:[NSString class]]) {
            return [NSString stringWithFormat:@"%@",converObject];
        } else {
            return [ANSJsonUtil convertToStringWithObject:converObject];
        }
    } @catch (NSException *exception) {
        ANSDebug(@"exception:%@",exception.description);
    }
}

/** iOS 回调 JS */
- (void)jsCallBackMethod:(NSString *)methodStr withWebView:(id)webView {
    methodStr = [[methodStr stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([webView isKindOfClass:NSClassFromString(@"WKWebView")]) {
        SEL evaluateSelector = NSSelectorFromString(@"evaluateJavaScript:completionHandler:");
        if (evaluateSelector) {
            typedef void(^CompletionBlock)(id, NSError *);
            IMP evaluateImp = [webView methodForSelector:evaluateSelector];
            void *(*func)(id, SEL, NSString *, CompletionBlock) = (void *(*)(id, SEL, NSString *, CompletionBlock))evaluateImp;
            func(webView, evaluateSelector, methodStr, nil);
        }
    }
}

#pragma mark - excute js event

/** 页面跳转事件 */
- (void)pageView:(NSArray *)param {
    if (param.count == 0) {
        return;
    }
    id pageId = param[0];
    if (![pageId isKindOfClass:[NSString class]]) {
        ANSBriefWarning(@"Hybrid: pageView identify must be string.");
        return;
    }
    if (param.count == 2) {
        id properties = param[1];
        if ([properties isKindOfClass:[NSDictionary class]]) {
            [AnalysysAgent pageView:pageId properties:properties];
        } else {
            ANSBriefWarning(@"Hybrid: pageView parameter must be {key:value}.");
        }
    } else {
        [AnalysysAgent pageView:pageId];
    }
}

/** track事件 */
- (void)track:(NSArray *)param {
    if (param.count == 0) {
        return;
    }
    NSString *eventId = param[0];
    if (![eventId isKindOfClass:[NSString class]]) {
        ANSBriefWarning(@"Hybrid: track identify must be string.");
        return;
    }
    if (param.count == 2) {
        id properties = param[1];
        if ([properties isKindOfClass:[NSDictionary class]]) {
            [AnalysysAgent track:eventId properties:properties];
        } else {
            ANSBriefWarning(@"Hybrid: track parameter must be {key:value}.");
        }
    } else {
        [AnalysysAgent track:eventId];
    }
}

#pragma mark - super property

/** 单个通用属性 */
- (void)registerSuperProperty:(NSArray *)param {
    if (param.count != 2) {
        ANSBriefWarning(@"Hybrid: registerSuperProperty parameter must be {key:value}.");
    }
    NSString *superPropertyName = param[0];
    id superPropertyValue = param[1];
    if (superPropertyName && superPropertyValue) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:superPropertyValue forKey:superPropertyName];
        [self registerHybirdSuperProperties:dic];
    }
}

/** 多个通用属性 */
- (void)registerSuperProperties:(NSArray *)param {
    if (param.count == 0) {
        return;
    }
    id properties = param[0];
    if ([properties isKindOfClass:[NSDictionary class]]) {
        [self registerHybirdSuperProperties:properties];
    } else {
        ANSBriefWarning(@"Hybrid: registerSuperProperty parameter must be {key:value}.");
    }
}

/** 删除通用属性中某个属性值 */
- (void)unRegisterSuperProperty:(NSArray *)param {
    if (param.count == 0) {
        return;
    }
    id superPropertyName = param[0];
    if ([superPropertyName isKindOfClass:[NSString class]]) {
        [self unRegisterHybirdSuperProperty:superPropertyName];
    } else {
        ANSBriefWarning(@"Hybrid: unRegisterSuperProperty parameter must be string.");
    }
}

/** 清除所有通用属性 */
- (void)clearSuperProperties:(NSArray *)param {
    [self clearHybirdSuperProperties];
}

/** 获取某个通用属性，并回调JS */
- (void)getSuperProperty:(NSArray *)param webView:(id)webView {
    if (param.count == 0) {
        return;
    }
    id superPropertyName = param[0];
    if ([superPropertyName isKindOfClass:[NSString class]]) {
        id superPropertyValue = [[AnalysysSDK sharedManager] getSuperProperty:superPropertyName];
        NSString *methodStr;
        if (superPropertyValue) {
            NSString *jsonString = [self jsonStringWithobject:superPropertyValue];
            methodStr = [NSString stringWithFormat:@"%@('%@')",param.lastObject,jsonString];
        } else {
            methodStr = [NSString stringWithFormat:@"%@('')",param.lastObject];
        }
        [self jsCallBackMethod:methodStr withWebView:webView];
    } else {
        ANSBriefWarning(@"Hybrid: getSuperProperty parameter must be string.");
    }
}

/** 获取所有通用属性，并回调JS */
- (void)getSuperProperties:(NSArray *)param webView:(id)webView {
    NSDictionary *superProperties = [[AnalysysSDK sharedManager] getSuperPropertiesValue];
    NSString *jsMethod;
    if (superProperties) {
        NSString *jsonStr = [self jsonStringWithobject:superProperties];
        jsMethod = [NSString stringWithFormat:@"%@('%@')",param.lastObject, jsonStr];
    } else {
        jsMethod = [NSString stringWithFormat:@"%@('')",param.lastObject];
    }
    [self jsCallBackMethod:jsMethod withWebView:webView];
}

#pragma mark - alias

/** 标识 */
- (void)identify:(NSArray *)param {
    if (param.count == 0) {
        return;
    }
    id distinctId = param[0];
    if ([distinctId isKindOfClass:[NSString class]]) {
        [AnalysysAgent identify:distinctId];
    } else {
        ANSBriefWarning(@"Hybrid: identify parameter must be string.");
    }
}

/** 身份关联 */
- (void)alias:(NSArray *)param {
    if (param.count == 1) {
        id aliasId = param[0];
        if ([aliasId isKindOfClass:[NSString class]]) {
            [AnalysysAgent alias:aliasId];
            return;
        }
    } else if (param.count == 2) {
        id aliasId = param[0];
        if ([aliasId isKindOfClass:[NSString class]]) {
            id originalId = param[1];
            if ([originalId isKindOfClass:[NSString class]] || originalId == nil) {
                [AnalysysAgent alias:aliasId originalId:originalId];
                return;
            }
        }
    }
    ANSBriefWarning(@"Hybrid: alias method must have 2 parameter.");
}

- (void)getDistinctId:(NSArray *)params webView:(id)webView {
    NSString *distinctId = [AnalysysAgent getDistinctId];
    NSString *jsMethod;
    if (distinctId) {
        jsMethod = [NSString stringWithFormat:@"%@('%@')",params.lastObject,distinctId];
    } else {
        jsMethod = [NSString stringWithFormat:@"%@('')",params.lastObject];
    }
    [self jsCallBackMethod:jsMethod withWebView:webView];
}

#pragma mark - profile

/** 用户信息设置 */
- (void)profileSet:(NSArray *)param {
    if (param.count == 0) {
        return;
    }
    id property = param[0];
    if ([property isKindOfClass:[NSDictionary class]]) {
        //  携带多个属性
        [AnalysysAgent profileSet:property];
        return;
    } else if ([property isKindOfClass:[NSString class]]) {
        if (param.count == 2) {
            id propertyValue = param[1];
            [AnalysysAgent profileSet:property propertyValue:propertyValue];
            return;
        }
    }
    ANSBriefWarning(@"Hybrid: profileSet parameter must be {key:value}.");
}

/** 首次设置用户的Profile的内容 */
- (void)profileSetOnce:(NSArray *)param {
    if (param.count == 0) {
        return;
    }
    id property = param[0];
    if ([property isKindOfClass:[NSDictionary class]]) {
        //  携带多个属性
        [AnalysysAgent profileSetOnce:property];
        return;
    } else if ([property isKindOfClass:[NSString class]]) {
        if (param.count == 2) {
            id propertyValue = param[1];
            [AnalysysAgent profileSetOnce:property propertyValue:propertyValue];
            return;
        }
    }
    ANSBriefWarning(@"Hybrid: profileSetOnce parameter must be {key:value}.");
}

/** 给数值类型的Profile增加数值 */
- (void)profileIncrement:(NSArray *)param {
    if (param.count == 0) {
        return;
    }
    id property = param[0];
    if ([property isKindOfClass:[NSDictionary class]]) {
        //  携带多个属性
        [AnalysysAgent profileIncrement:property];
        return;
    } else if ([property isKindOfClass:[NSString class]]) {
        if (param.count == 2) {
            id propertyValue = param[1];
            if ([propertyValue isKindOfClass:[NSNumber class]]) {
                [AnalysysAgent profileIncrement:property propertyValue:propertyValue];
                return;
            }
        }
    }
    ANSBriefWarning(@"Hybrid: profileIncrement parameter key must be string, value number.");
}

/** 向prifile中追加属性 */
- (void)profileAppend:(NSArray *)param {
    if (param.count == 0) {
        return;
    }
    id property = param[0];
    if ([property isKindOfClass:[NSDictionary class]]) {
        //  携带多个属性
        [AnalysysAgent profileAppend:property];
        return;
    } else if ([property isKindOfClass:[NSString class]]) {
        if (param.count == 2) {
            id propertyValue = param[1];
            if ([propertyValue isKindOfClass:[NSArray class]]) {
                [AnalysysAgent profileAppend:property propertyValue:propertyValue];
            } else {
                [AnalysysAgent profileAppend:property value:propertyValue];
            }
            return;
        }
    }
    ANSBriefWarning(@"Hybrid: check profileAppend.");
}

/** 删除某个Profile key对应的全部内容 */
- (void)profileUnset:(NSArray *)param {
    if (param.count == 0) {
        return;
    }
    id propertyName = param[0];
    if ([propertyName isKindOfClass:[NSString class]]) {
        [AnalysysAgent profileUnset:propertyName];
    } else {
        ANSBriefWarning(@"Hybrid: profileUnset paramter must be string.");
    }
}

/** 删除当前profile所有记录 */
- (void)profileDelete:(NSArray *)param {
    [AnalysysAgent profileDelete];
}

- (void)reset:(NSArray *)param {
    [AnalysysAgent reset];
}

/** 预置属性*/
- (void)getPresetProperties:(NSArray *)param webView:(id)webView {
    NSDictionary *presetProperties = [[AnalysysSDK sharedManager] getPresetProperties];
    NSString *jsMethod;
    if (presetProperties) {
        NSString *jsonStr = [self jsonStringWithobject:presetProperties];
        jsMethod = [NSString stringWithFormat:@"%@('%@')",param.lastObject, jsonStr];
    } else {
        jsMethod = [NSString stringWithFormat:@"%@('')",param.lastObject];
    }
    [self jsCallBackMethod:jsMethod withWebView:webView];
}

#pragma mark - hybird通用属性

/** 注册hybird通用属性 */
- (void)registerHybirdSuperProperties:(NSDictionary *)superProperties {
    ANSDataCheckLog *checkResult = [ANSDataCheckRouter checkSuperProperties:&superProperties];
    if (checkResult && checkResult.resultType <= AnalysysResultSuccess) {
        ANSBriefWarning(@"%@",[checkResult messageDisplay]);
        if (superProperties == nil) {
            return;
        }
    }
    ANSPropertyLock();
    NSDictionary *tmp = [ANSFileManager unarchiveHybridSuperProperties];
    NSMutableDictionary *hybirdSuperProperty = [NSMutableDictionary dictionaryWithDictionary:tmp];
    [hybirdSuperProperty addEntriesFromDictionary:superProperties];
    BOOL result = [ANSFileManager archiveHybridSuperProperties:hybirdSuperProperty];
    ANSPropertyUnlock();
    if (result) {
        ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultSetSuccess;
        ANSLog(@"%@",[checkResult messageDisplay]);
    } else {
        ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultSetFailed;
        ANSBriefWarning(@"%@",[checkResult messageDisplay]);
    }
}

/** 删除hybird单个通用属性 */
- (void)unRegisterHybirdSuperProperty:(NSString *)superPropertyName {
    ANSPropertyLock();
    NSDictionary *tmp = [ANSFileManager unarchiveHybridSuperProperties];
    NSMutableDictionary *hybirdSuperProperty = [NSMutableDictionary dictionaryWithDictionary:tmp];
    [hybirdSuperProperty removeObjectForKey:superPropertyName];
    BOOL result = [ANSFileManager archiveHybridSuperProperties:hybirdSuperProperty];
    ANSPropertyUnlock();
    if (result) {
        ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.value = superPropertyName;
        checkResult.resultType = AnalysysResultSetSuccess;
        ANSLog(@"%@",[checkResult messageDisplay]);
    }
}

/** 清除hybird所有通用属性 */
- (void)clearHybirdSuperProperties {
    ANSPropertyLock();
    BOOL result = [ANSFileManager archiveHybridSuperProperties:[NSDictionary dictionary]];
    ANSPropertyUnlock();
    if (result) {
        ANSDataCheckLog *checkResult = [[ANSDataCheckLog alloc] init];
        checkResult.resultType = AnalysysResultSetSuccess;
        ANSLog(@"%@",[checkResult messageDisplay]);
    }
}


@end

