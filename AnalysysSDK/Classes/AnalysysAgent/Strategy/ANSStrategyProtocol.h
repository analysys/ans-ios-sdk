//
//  ANSStrategyProtocol.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/1/18.
//  Copyright © 2019 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @protcol
 * ANSStrategyProtocol
 *
 * @abstract
 * 策略协议
 *
 * @discussion
 * 策略模块使用的协议方法
 */

NS_ASSUME_NONNULL_BEGIN

@protocol ANSStrategyProtocol <NSObject>

@optional

/**
 序列化策略信息
 */
- (void)archiveStrategy;

/**
 反序列化策略信息

 @return strategy
 */
+ (instancetype)unarchiveStrategy;

/**
 是否可进行数据上传
 
 @param dataCount 本地缓存数据条数
 @return result
 */
- (BOOL)canUploadWithDataCount:(NSInteger)dataCount;

@end

NS_ASSUME_NONNULL_END
