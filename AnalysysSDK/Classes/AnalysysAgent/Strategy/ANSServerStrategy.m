//
//  ANSServerStrategy.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/1/17.
//  Copyright © 2019 analysys. All rights reserved.
//

#import "ANSServerStrategy.h"
#import "ANSFileManager.h"
#import "ANSStrategyManager.h"

#define ANS_SERVER_STRATEGY_PATH [ANSFileManager filePathWithName:@"ANSServerStrategy.plist"]

static BOOL ANSCanSendData = YES;//  控制是否再次发起延迟策略

@implementation ANSServerStrategy

- (instancetype)init {
    self = [super init];
    if (self) {
        _hashCode = @"";
        _debugMode = -1;
        _strategyType = AnsNoStrategy;
    }
    return self;
}

#pragma mark - public method

- (void)parseServerStrategyInfo:(NSDictionary *)serverInfo {
    NSArray *allKeys = serverInfo.allKeys;
    if ([allKeys containsObject:@"hash"]) {
        self.hashCode = serverInfo[@"hash"];
    }
    if ([allKeys containsObject:@"debugMode"]) {
        self.debugMode = [serverInfo[@"debugMode"] integerValue];
    } else {
        self.debugMode = -1;
    }
    if ([allKeys containsObject:@"serverUrl"]) {
        self.serverUrl = serverInfo[@"serverUrl"];
    } else {
        self.serverUrl = @"";
    }
    if ([allKeys containsObject:@"policyNo"]) {
        self.strategyType = [serverInfo[@"policyNo"] integerValue];
    } else {
        self.strategyType = AnsNoStrategy;
    }
    if ([allKeys containsObject:@"timerInterval"]) {
        self.flushInterval = [serverInfo[@"timerInterval"] integerValue];
    } else {
        self.flushInterval = -1;
    }
    if ([allKeys containsObject:@"eventCount"]) {
        self.flushBulkSize = [serverInfo[@"eventCount"] integerValue];
    } else {
        self.flushBulkSize = -1;
    }
    if ([allKeys containsObject:@"failCount"]) {
        self.maxAllowFailedCount = [serverInfo[@"failCount"] integerValue];
    } else {
        self.maxAllowFailedCount = -1;
    }
    if ([allKeys containsObject:@"failTryDelay"]) {
        self.maxFailTryDelay = [serverInfo[@"failTryDelay"] integerValue];
    } else {
        self.maxFailTryDelay = -1;
    }
    
    [self archiveStrategy];
}

#pragma mark - ANSStrategyProtocol

- (void)archiveStrategy {
    @try {
        [NSKeyedArchiver archiveRootObject:self toFile:ANS_SERVER_STRATEGY_PATH];
    } @catch (NSException *exception) {
        
    }
}

+ (instancetype)unarchiveStrategy {
    @try {
        NSData *data = [[NSData alloc] initWithContentsOfFile:ANS_SERVER_STRATEGY_PATH];
        if (data.length == 0) {
            return [[ANSServerStrategy alloc] init];
        }
        return [NSKeyedUnarchiver unarchiveObjectWithFile:ANS_SERVER_STRATEGY_PATH];
    } @catch (NSException *exception) {
        return [[ANSServerStrategy alloc] init];
    }
}

- (BOOL)canUploadWithDataCount:(NSInteger)dataCount {
    //  debug模式或实时上传策略
    if (self.strategyType == AnsRealTime ||
        [ANSStrategyManager sharedManager].currentUseDebugMode != 0) {
        return YES;
    }
    
    if (self.strategyType == AnsSmart) {
        
        if (self.flushBulkSize > 0 && self.flushInterval > 0) {
            if (dataCount >= self.flushBulkSize) {
                return YES;
            }
            
            [self upIntergerStrategy];
            return NO;
        }
        
    }
    //  间隔发送
    if (self.strategyType == AnsInterval) {
        [self upIntergerStrategy];
        return NO;
    }
    return NO;
}

//  间隔发送
- (void)upIntergerStrategy {
    if (ANSCanSendData && self.flushInterval > 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.flushInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ANSFlushDataNotification object:nil];
            //  发送数据上传通知
            ANSCanSendData = YES;
        });
        ANSCanSendData = NO;
    }
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    @try {
        [aCoder encodeObject:_hashCode forKey:@"hashCode"];
        [aCoder encodeObject:_serverUrl forKey:@"serverUrl"];
        [aCoder encodeInteger:_strategyType forKey:@"strategyType"];
        [aCoder encodeInteger:_debugMode forKey:@"debugMode"];
        [aCoder encodeInteger:_flushInterval forKey:@"flushInterval"];
        [aCoder encodeInteger:_flushBulkSize forKey:@"flushBulkSize"];
        [aCoder encodeInteger:_maxAllowFailedCount forKey:@"maxAllowFailedCount"];
        [aCoder encodeInteger:_maxFailTryDelay forKey:@"maxFailTryDelay"];
    } @catch (NSException *exception) {
        
    }
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _hashCode = [coder decodeObjectForKey:@"hashCode"];
        _serverUrl = [coder decodeObjectForKey:@"serverUrl"];
        _strategyType = [coder decodeIntegerForKey:@"strategyType"];
        _debugMode = [coder decodeIntegerForKey:@"debugMode"];
        _flushInterval = [coder decodeIntegerForKey:@"flushInterval"];
        _flushBulkSize = [coder decodeIntegerForKey:@"flushInterval"];
        _maxAllowFailedCount = [coder decodeIntegerForKey:@"maxAllowFailedCount"];
        _maxFailTryDelay = [coder decodeIntegerForKey:@"maxFailTryDelay"];
    }
    return self;
}


@end
