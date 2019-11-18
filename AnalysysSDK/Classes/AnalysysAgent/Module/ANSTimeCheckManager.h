//
//  ANSTimeCheckManager.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/10/31.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANSTimeCheckManager : NSObject

+ (instancetype)shared;

/// 时间校准请求是否完成
- (BOOL)timeCheckRequestIsFinished;

/// 请求服务器
/// @param serverUrl 地址
/// @param block 请求返回回调
- (void)requestWithServer:(NSString *)serverUrl block:(void(^)(void))block;

/// 进行数据校验
/// @param dataArray 原始数据
- (NSArray *)checkDataArray:(NSArray *)dataArray;

@end


