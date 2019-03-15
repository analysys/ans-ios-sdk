//
//  ANSStrategyManager.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/1/17.
//  Copyright © 2019 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ANSServerStrategy.h"
#import "ANSUserStrategy.h"
#import "ANSDefaultStrategy.h"
#import "ANSDelayStrategy.h"

/** 满足上传策略 */
extern NSString *const ANSFlushDataNotification;
/** 取消现有队列其他上传操作 */
extern NSString *const ANSCancelOperationQueueNotification;


/**
 * @class
 * ANSStrategyManager
 *
 * @abstract
 * 策略管理类
 *
 * @discussion
 * 共三类策略：优先级:服务器 > 用户设置 > 默认值
 例：若服务器下发不完整策略，如仅仅下发策略类型为0（智能策略），不带有X秒/Y条，则查看用户是否设置两个选项，若有则使用用户设置参数，若没有则使用默认参数;若服务器下发策略类型为0（智能策略），并带有30秒/10条，则使用此策略上传
 */


@interface ANSStrategyManager : NSObject

/** 服务器下发策略 */
@property (nonatomic, strong) ANSServerStrategy *serverStrategy;
/** 用户设置策略 */
@property (nonatomic, strong) ANSUserStrategy *userStrategy;
/** 默认策略 */
@property (nonatomic, strong) ANSDefaultStrategy *defaultStrategy;
/** 延迟策略 */
@property (nonatomic, strong) ANSDelayStrategy *delayStrategy;

/** 当前使用的Debug状态 */
@property (nonatomic, assign) NSInteger currentUseDebugMode;
/** 当前使用的server地址 */
@property (nonatomic, copy) NSString *currentUseServerUrl;
/** 当前最大允许失败次数 */
@property (nonatomic, assign) NSInteger currentUseMaxAllowFailedCount;

+ (instancetype)sharedManager;


/**
 保存服务器下发策略

 @param serverInfo strategyInfo
 */
+ (void)saveServerStrategyInfo:(NSDictionary *)serverInfo;

/**
 是否可进行数据上传

 @param dataCount 本地缓存数据条数
 @return result
 */
- (BOOL)canUploadWithDataCount:(NSInteger)dataCount;



@end


