//
//  ANSQueue.h
//  AnalysysAgent
//
//  Created by xiao xu on 2019/10/11.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ANSQueue : NSObject

/// 异步数据处理串行队列
/// @param dispatchBlock 回调
+ (void)dispatchAsyncLogSerialQueueWithBlock:(void(^)(void))dispatchBlock;

/// 同步数据处理串行队列
/// @param dispatchBlock 回调
+ (void)dispatchSyncLogSerialQueueWithBlock:(void(^)(void))dispatchBlock;

/// 延迟执行
/// @param second 延迟时间 单位：秒
/// @param dispatchBlock 回调
+ (void)dispatchAfterSeconds:(float)second
   onLogSerialQueueWithBlock:(void(^)(void))dispatchBlock;

/// 数据上传串行队列
/// @param dispatchBlock 回调
+ (void)dispatchRequestSerialQueueWithBlock:(void(^)(void))dispatchBlock;
@end

NS_ASSUME_NONNULL_END
