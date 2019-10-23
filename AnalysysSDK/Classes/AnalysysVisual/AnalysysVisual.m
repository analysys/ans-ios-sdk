//
//  AnalysysVisual.m
//  AnalysysAgent
//
//  Created by analysys on 2018/3/22.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "AnalysysVisual.h"

#import "ANSVisualSDK.h"

@implementation AnalysysVisual

#pragma mark - SDK配置

/** 初始化埋点及下发地址 */
+ (void)setVisualBaseUrl:(NSString *)baseUrl {
    [[ANSVisualSDK sharedManager] setVisualBaseUrl:baseUrl];
}

/** 修改可视化埋点系统地址 */
+ (void)setVisualServerUrl:(NSString *)visualUrlStr {
    [[ANSVisualSDK sharedManager] setVisualServerUrl:visualUrlStr];
}

/** 修改可视化埋点（已绑定事件）配置下发地址 */
+ (void)setVisualConfigUrl:(NSString *)configUrl {
    [[ANSVisualSDK sharedManager] setVisualConfigUrl:configUrl];
}


@end
