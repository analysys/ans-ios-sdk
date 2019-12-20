//
//  ANSVisualSDK.h
//  AnalysysVisual
//
//  Created by SoDo on 2019/2/12.
//  Copyright © 2019 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ANSVisualSDK : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, copy) NSString *currentPage;//  当前点击页面
@property (nonatomic, copy) NSString *controlText;//  控件文本


#pragma mark - SDK配置

/** 初始化埋点及下发地址 */
- (void)setVisualBaseUrl:(NSString *)baseUrl;

/** 设置可视化埋点地址 */
- (void)setVisualServerUrl:(NSString *)visualUrl;

/** 设置可视化埋点配置下发地址 */
- (void)setVisualConfigUrl:(NSString *)configUrl;


#pragma mark - 可视化操作

/**
 触发可视化埋点事件
 
 @param trackView 控件对象
 @param event 事件标识
 */
- (void)trackObject:(id)trackView withEvent:(NSString *)event;


@end


