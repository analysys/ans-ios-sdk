//
//  ANSModuleProcessing.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/3/7.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSModuleProcessing.h"
#import "ANSModuleConfig.h"
#import "ANSMediator.h"

@interface ANSModuleProcessing ()

@property (nonatomic, strong) NSDictionary *configInfo;

@end

@implementation ANSModuleProcessing

+ (instancetype)sharedManager {
    static id singleInstance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        if (!singleInstance) {
            singleInstance = [[self alloc] init] ;
        }
    });
    return singleInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _configInfo = [ANSModuleConfig allModuleConfig];
    }
    return self;
}

#pragma mark - 加密模块

+ (NSDictionary *)extroHeaderInfo {
    NSString *funcString = [ANSModuleProcessing sharedManager].configInfo[@"Upload"][@"start"];
    if (funcString.length > 0) {
        return [ANSModuleProcessing excuteFuncString:funcString param:nil];
    }
    return nil;
}

+ (id)encryptJsonString:(NSString *)jsonString param:(NSDictionary *)param {
    NSString *funcString = [ANSModuleProcessing sharedManager].configInfo[@"Encrypt"][@"start"];
    if (funcString.length > 0 && jsonString.length > 0 && param != nil) {
        NSString *encryptString = [ANSModuleProcessing excuteFuncString:funcString param:@[jsonString, param]];
        jsonString = encryptString ?: jsonString;
    }
    return jsonString;
}

#pragma mark - 可视化模块

+ (void)setVisualBaseUrl:(NSString *)baseUrl {
    NSString *funcString = [ANSModuleProcessing sharedManager].configInfo[@"VisualBase"][@"start"];
    if (funcString.length > 0) {
        [ANSModuleProcessing excuteFuncString:funcString param:@[baseUrl]];
    }
}

+ (void)setVisitorDebugURL:(NSString *)visitorDebugURL {
    NSString *funcString = [ANSModuleProcessing sharedManager].configInfo[@"Visual"][@"start"];
    if (funcString.length > 0 && visitorDebugURL.length > 0) {
        [ANSModuleProcessing excuteFuncString:funcString param:@[visitorDebugURL]];
    }
}

+ (void)setVisualConfigUrl:(NSString *)configUrl {
    NSString *funcString = [ANSModuleProcessing sharedManager].configInfo[@"VisualConfig"][@"start"];
    if (funcString.length > 0 && configUrl.length > 0) {
        [ANSModuleProcessing excuteFuncString:funcString param:@[configUrl]];
    }
}

#pragma mark - 推送模块

+ (BOOL)existsPushModule {
    Class cls = NSClassFromString(@"AnalysysPush");
    if (cls) {
        return YES;
    }
    return NO;
}

+ (NSDictionary *)parsePushInfo:(id)parameter {
    NSString *funcString = [ANSModuleProcessing sharedManager].configInfo[@"PushParse"][@"start"];
    if (funcString.length > 0 && parameter != nil) {
        return [ANSModuleProcessing excuteFuncString:funcString param:@[parameter]];
    }
    return nil;
}

+ (NSDictionary *)parsePushContext:(id)parameter {
    NSString *funcString = [ANSModuleProcessing sharedManager].configInfo[@"PushSplice"][@"start"];
    if (funcString.length > 0 && parameter != nil) {
        return [ANSModuleProcessing excuteFuncString:funcString param:@[parameter]];
    }
    return nil;
}

+ (void)pushClickParameter:(id)parameter {
    NSString *funcString = [ANSModuleProcessing sharedManager].configInfo[@"PushClick"][@"start"];
    if (funcString.length > 0 && parameter != nil) {
        [ANSModuleProcessing excuteFuncString:funcString param:@[parameter]];
    }
}

#pragma mark - private

+ (id)excuteFuncString:(NSString *)funcStr param:(NSArray *)paramArray {
    id dataValue ;
    NSArray *array = [funcStr componentsSeparatedByString:@"."];
    if (array.count == 2) {
        Class cls = NSClassFromString(array[0]);
        NSString *funcStr = array[1];
        if (cls) {
            if (paramArray.count > 0) {
                dataValue = [ANSMediator performTarget:cls action:funcStr params:paramArray];
            } else {
                dataValue = [ANSMediator performTarget:cls action:funcStr];
            }
        }
    }
    return dataValue;
}

@end
