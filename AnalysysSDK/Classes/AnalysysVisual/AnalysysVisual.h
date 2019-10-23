//
//  AnalysysVisual.h
//  AnalysysAgent
//
//  Created by analysys on 2018/3/22.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class
 * AnalysysVisual
 *
 * @abstract
 * 可视化模块
 *
 * @discussion
 * 可视化埋点及埋点处理
 */

@interface AnalysysVisual : NSObject


#pragma mark - 可视化SDK配置


/**
 初始化埋点及下发地址

 @param baseUrl 基础地址，不包含协议及端口，如：sdk.analysys.cn
 */
+ (void)setVisualBaseUrl:(NSString *)baseUrl;

/**
 设置可视化埋点地址
 
 @param visualUrlStr 可视化地址，包含协议及端口，如：wss://arksdk.analysys.cn:4091
 */
+ (void)setVisualServerUrl:(NSString *)visualUrlStr;

/**
 设置可视化埋点配置下发地址

 @param configUrl 配置地址，包含协议及端口，如：https://arksdk.analysys.cn:4089
 */
+ (void)setVisualConfigUrl:(NSString *)configUrl;



@end
