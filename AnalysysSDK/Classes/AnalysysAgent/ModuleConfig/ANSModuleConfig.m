//
//  ANSModuleConfig.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/3/7.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSModuleConfig.h"
#import "ANSBundleUtil.h"

@implementation ANSModuleConfig

+ (NSDictionary *)allModuleConfig {
    NSDictionary *dModuleConfig = [ANSBundleUtil loadConfigsWithFileName:@"DefaultLifeCycleConfig" fileType:@"json"];
    NSDictionary *cModuleConfig = [ANSBundleUtil loadConfigsWithFileName:@"CustomerLifeCycleConfig" fileType:@"json"];
    
    NSMutableDictionary *moduleConfig = [NSMutableDictionary dictionaryWithDictionary:dModuleConfig];
    // 1. 以默认模板为基准合并
    for (NSString *key in dModuleConfig.allKeys) {
        if ([cModuleConfig.allKeys containsObject:key]) {
            [moduleConfig setValue:[cModuleConfig objectForKey:key] forKey:key];
        }
    }
    // 2. 合并自定义多出字段
    NSMutableSet *cMudleKeySet = [NSMutableSet setWithArray:cModuleConfig.allKeys];
    NSMutableSet *dMudleKeySet = [NSMutableSet setWithArray:dModuleConfig.allKeys];
    [cMudleKeySet minusSet:dMudleKeySet];
    for (NSString *key in cMudleKeySet) {
        [moduleConfig setValue:[cModuleConfig objectForKey:key] forKey:key];
    }
    
    return moduleConfig;
}

@end
