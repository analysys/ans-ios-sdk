//
//  ANSHybrid.h
//  AnalysysAgent
//
//  Created by SoDo on 2018/7/23.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class
 * ANSHybrid
 *
 * @abstract
 * Hybrid模块：H5混合页面数据处理
 *
 * @discussion
 * H5页面埋点与原生App交互，H5方法名称与原生方法名称一致，通过反射调用
 * 可能还会包含Hybrid可视化相关内容
 */

@interface ANSHybrid : NSObject


/**
 统计WKWebView

 @param request NSURLRequest请求对象
 @param webView webView对象
 @return 是否统计
 */
+ (BOOL)excuteRequest:(NSURLRequest *)request webView:(id)webView;


/**
 删除 自定义的 UserAgent
 */
+ (void)resetHybridModel;


@end

