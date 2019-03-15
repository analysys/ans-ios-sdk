//
//  ANSStrategyManager.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/1/17.
//  Copyright © 2019 analysys. All rights reserved.
//

#import "ANSStrategyManager.h"
#import "ANSConsleLog.h"

NSString *const ANSFlushDataNotification = @"ANSFlushDataNotification";
NSString *const ANSCancelOperationQueueNotification = @"ANSCancelOperationQueueNotification";

@implementation ANSStrategyManager

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
        self.serverStrategy = [ANSServerStrategy unarchiveStrategy];
        self.userStrategy = [ANSUserStrategy unarchiveStrategy];
        self.defaultStrategy = [[ANSDefaultStrategy alloc] init];
        self.delayStrategy = [ANSDelayStrategy unarchiveStrategy];
    }
    return self;
}

#pragma mark *** public method ***

- (NSInteger)currentUseDebugMode {
    if (self.serverStrategy.debugMode >= 0) {
        return self.serverStrategy.debugMode;
    }
    if (self.userStrategy.debugMode >= 0) {
        return self.userStrategy.debugMode;
    }
    return self.defaultStrategy.debugMode;
}

- (NSString *)currentUseServerUrl {
    if (self.serverStrategy.serverUrl.length > 0) {
        return self.serverStrategy.serverUrl;
    }
    if (self.userStrategy.serverUrl.length > 0) {
        return self.userStrategy.serverUrl;
    }
    return nil;
}

- (NSInteger)currentUseMaxAllowFailedCount {
    if (self.serverStrategy.maxAllowFailedCount) {
        return self.serverStrategy.maxAllowFailedCount;
    }
    return self.defaultStrategy.maxAllowFailedCount;
}

+ (void)saveServerStrategyInfo:(NSDictionary *)serverInfo {
    [[ANSStrategyManager sharedManager].serverStrategy parseServerStrategyInfo:serverInfo];
}

- (BOOL)canUploadWithDataCount:(NSInteger)dataCount {
    // 1. 是否存在延迟策略
    if (![self.delayStrategy canUploadWithDataCount:dataCount]) {
        return NO;
    }
    // 2. 当前策略下是否满足上传数据
    return [[self currentStrategy] canUploadWithDataCount:dataCount];
}

- (id<ANSStrategyProtocol>)currentStrategy {
    if (self.serverStrategy.strategyType != AnsNoStategy) {
        return self.serverStrategy;
    }
    if (self.userStrategy.flushInterval > 0  || self.userStrategy.flushBulkSize > 0) {
        return self.userStrategy;
    }
    return self.defaultStrategy;
}

@end
