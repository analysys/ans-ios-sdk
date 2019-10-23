//
//  ANSModuleProcessing.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/3/7.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ANSModuleProcessing : NSObject


#pragma mark - 加密模块

/**
 数据上传请求额外信息

 @return header
 */
+ (NSDictionary *)extroHeaderInfo;

/**
 加密上传数据

 @param jsonString 原始上传数据
 @param param header参数(用于计算的参数)
 @return 加密数据
 */
+ (id)encryptJsonString:(NSString *)jsonString param:(NSDictionary *)param;

#pragma mark - 可视化模块

/**
 初始化可视化 ws及config地址

 @param baseUrl 基础地址
 */
+ (void)setVisualBaseUrl:(NSString *)baseUrl;

/**
 初始化可视化模块ws地址

 @param visitorDebugURL ws地址
 */
+ (void)setVisitorDebugURL:(NSString *)visitorDebugURL;

/**
 初始化可视化配置下发地址

 @param configUrl 配置地址
 */
+ (void)setVisualConfigUrl:(NSString *)configUrl;

#pragma mark - 推送模块

+ (BOOL)existsPushModule;

/**
 反射调用 带有返回值
 
 @param parameter 参数
 @return 数据信息
 */
+ (NSDictionary *)parsePushInfo:(id)parameter;
+ (NSDictionary *)parsePushContext:(id)parameter;

/** 点击推送 */
+ (void)pushClickParameter:(id)parameter;



@end


