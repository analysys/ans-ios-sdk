//
//  ANSStrategyManager.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/1/17.
//  Copyright © 2019 analysys. All rights reserved.
//

#import "ANSStrategyManager.h"

#import "ANSServerStrategy.h"
#import "ANSUserStrategy.h"
#import "ANSDefaultStrategy.h"
#import "ANSDelayStrategy.h"

NSString *const ANSFlushDataNotification = @"ANSFlushDataNotification";
NSInteger ANSTimeInterval = 0;

@implementation ANSStrategyManager{
    NSLock *_strategyLock;
}

+ (instancetype)sharedManager {
    static id singleInstance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        if (!singleInstance) {
            singleInstance = [[self alloc] init] ;
        }
    });
    return singleInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _strategyLock = [[NSLock alloc] init];
        self.serverStrategy = [ANSServerStrategy unarchiveStrategy];
        self.userStrategy = [ANSUserStrategy unarchiveStrategy];
        self.defaultStrategy = [[ANSDefaultStrategy alloc] init];
        self.delayStrategy = [ANSDelayStrategy unarchiveStrategy];
    }
    return self;
}

#pragma mark - public method

- (NSInteger)currentUseDebugMode {
    NSInteger retValue = 0;
    [_strategyLock lock];
    if (self.serverStrategy.debugMode >= 0) {
        retValue = self.serverStrategy.debugMode;
    } else if (self.userStrategy.debugMode >= 0) {
        retValue = self.userStrategy.debugMode;
    } else {
        retValue = self.defaultStrategy.debugMode;
    }
    [_strategyLock unlock];
    return retValue;
}

- (NSString *)currentUrl {
    NSString *retValue = nil;
    if (self.serverStrategy.serverUrl.length > 0) {
        retValue = [self.serverStrategy.serverUrl copy];
    } else if (self.userStrategy.serverUrl.length > 0) {
        retValue = [self.userStrategy.serverUrl copy];
    } else {
        retValue = nil;
    }
    return retValue;
}

- (NSInteger)currentUseMaxAllowFailedCount {
    NSInteger retValue;
    if (self.serverStrategy.maxAllowFailedCount) {
        retValue = self.serverStrategy.maxAllowFailedCount;
    } else {
        retValue = self.defaultStrategy.maxAllowFailedCount;
    }
    return retValue;
}

+ (void)saveServerStrategyInfo:(NSDictionary *)serverInfo {
    [[ANSStrategyManager sharedManager].serverStrategy parseServerStrategyInfo:serverInfo];
}

- (BOOL)canUploadWithDataCount:(NSInteger)dataCount {
    // 1. 是否存在延迟策略
    BOOL retValue;
    if (![self.delayStrategy canUploadWithDataCount:dataCount]) {
        retValue = NO;
    } else {
        // 2. 当前策略下是否满足上传数据
        retValue = [[self currentStrategy] canUploadWithDataCount:dataCount];
    }
    return retValue;
}

- (id<ANSStrategyProtocol>)currentStrategy {
    if (self.serverStrategy.strategyType != AnsNoStrategy) {
        return self.serverStrategy;
    }
    if (self.userStrategy.flushInterval > 0 && self.userStrategy.flushBulkSize > 0) {
        return self.userStrategy;
    }
    return self.defaultStrategy;
}

- (void)resetStrategy {
    [_strategyLock lock];
    [self resetServerStrategy];
    [self resetDelayStrategy];
    [_strategyLock unlock];
}

/** 重置服务器策略 */
- (void)resetServerStrategy {
    self.serverStrategy = [[ANSServerStrategy alloc] init];
    [self.serverStrategy archiveStrategy];
}

/** 重置延迟策略 */
- (void)resetDelayStrategy {
    self.delayStrategy = [[ANSDelayStrategy alloc] init];
    [self.delayStrategy archiveStrategy];
}

/** 服务器下发策略标识 */
- (NSString *)getServerhashCodeValue {
    NSString *retValue ;
    retValue = [[ANSStrategyManager sharedManager].serverStrategy.hashCode copy];
    return retValue;
}

/** 设置debug */
- (void)setUserDebugModeValue:(AnalysysDebugMode)value {
    [_strategyLock lock];
    self.userStrategy.debugMode = value;
    [_strategyLock unlock];
}

/** 用户自定义上报地址 */
- (void)setUserServerUrlValue:(NSString *)value {
    self.userStrategy.serverUrl = value;
}

/** 设置自定义间隔时间 */
- (void)setUserIntervalTimeValue:(NSInteger)value {
    self.userStrategy.flushInterval = value;
}

/** 设置最大事件条数 */
- (void)setUserMaxEventSizeValue:(NSInteger)value {
    self.userStrategy.flushBulkSize = value;
}

/** 增加失败次数 */
- (void)increaseDelayStrategyFailCount {
    self.delayStrategy.currentFailedCount ++;
    //  达到最大失败次数 执行延迟
    if (self.delayStrategy.currentFailedCount >= self.currentUseMaxAllowFailedCount+1) {
        self.delayStrategy.failDelayDate = [NSDate date];
        self.delayStrategy.currentFailedCount = 0;
        return;
    }
    //  普通上传失败重传
    NSInteger failedNextInterval = 5 + arc4random() % 10;
    [self.delayStrategy canExcuteUpload:failedNextInterval];
    [self.delayStrategy archiveStrategy];
}

/** 重置失败 */
- (void)resetDelayStrategyFailedTry {
    if (self.delayStrategy.currentFailedCount) {
        self.delayStrategy.currentFailedCount = 0;
        self.delayStrategy.failDelayDate = nil;
        ANSTimeInterval = [[NSDate date] timeIntervalSince1970];
        [self.delayStrategy archiveStrategy];
    }
}


@end
