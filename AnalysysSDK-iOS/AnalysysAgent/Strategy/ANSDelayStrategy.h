//
//  ANSDelayStrategy.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/1/18.
//  Copyright © 2019 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANSStrategyProtocol.h"
/**
 * @class
 * ANSDelayStrategy
 *
 * @abstract
 * 延迟信息
 *
 * @discussion
 * 失败延迟信息
 */

NS_ASSUME_NONNULL_BEGIN

@interface ANSDelayStrategy : NSObject<NSCoding, ANSStrategyProtocol>

/** 以下两个属性计算使用 需存储本地 */
/**
 当前累积上传失败次数
 */
@property (nonatomic, assign) NSInteger currentFailedCount;

/**
 达到失败最多次数后的时间点
 */
@property (nonatomic, strong, nullable) NSDate *failDelayDate;

/**
 增加一次上传失败次数
 */
- (void)increaseFailCount;

/**
 上传充公后重置失败策略
 */
- (void)resetFailedTry;



@end

NS_ASSUME_NONNULL_END
