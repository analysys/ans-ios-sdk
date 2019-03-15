//
//  ANSServerStrategy.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/1/17.
//  Copyright © 2019 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANSStrategyProtocol.h"

/**
 策略类型
 
 - AnsSmart: 智能策略 X秒/Y条
 - AnsRealTime: 触发事件即上传
 - AnsInterval: 间隔发送
 */
typedef enum : NSUInteger {
    AnsSmart = 0,  //  智能策略 X秒/Y条
    AnsRealTime, //  触发事件即上传
    AnsInterval,  //  间隔发送
    AnsNoStategy  // 默认无策略
} AnsStrategyType;

/**
 * @class
 * ANSServerStrategy
 *
 * @abstract
 * 服务器策略
 *
 * @discussion
 * 接收服务器下发策略信息
 */


NS_ASSUME_NONNULL_BEGIN

@interface ANSServerStrategy : NSObject<NSCoding, ANSStrategyProtocol>

/**
 用于校验本地与服务器策略版本是否一致
 */
@property (nonatomic, copy) NSString *hashCode;

/**
 策略类型
 默认999 无策略
 */
@property (nonatomic, assign) AnsStrategyType strategyType;

/**
 debug模式
 默认 AnsNoStategy 正常值对应 AnalysysDebugMode
 */
@property (nonatomic, assign) NSInteger debugMode;

/**
 数据上传地址
 */
@property (nonatomic, copy) NSString *serverUrl;

/**
 上传数据间隔
 */
@property (nonatomic, assign) NSInteger flushInterval;

/**
 累积X条数据后 上传
 */
@property (nonatomic, assign) NSInteger flushBulkSize;

/**
 上传允许失败最大次数
 */
@property (nonatomic, assign) NSInteger maxAllowFailedCount;

/**
 达到上传最多次数后延迟后，下次上传间隔
 */
@property (nonatomic, assign) NSInteger maxFailTryDelay;



/**
 解析服务器下发策略信息

 @param serverInfo 服务器信息
 */
- (void)parseServerStrategyInfo:(NSDictionary *)serverInfo;


@end

NS_ASSUME_NONNULL_END
