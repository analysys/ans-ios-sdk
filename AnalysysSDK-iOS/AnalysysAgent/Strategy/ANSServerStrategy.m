//
//  ANSServerStrategy.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/1/17.
//  Copyright © 2019 analysys. All rights reserved.
//

#import "ANSServerStrategy.h"
#import "ANSFileManager.h"
#import "ANSConsleLog.h"
#import "ANSTelephonyNetwork.h"
#import "ANSStrategyManager.h"

#define serverStrategyPath [ANSFileManager filePathWithName:@"ANSServerStrategy.plist"]

static BOOL allowDispatch = YES;//  控制是否再次发起延迟策略

@implementation ANSServerStrategy

- (instancetype)init {
    self = [super init];
    if (self) {
        _hashCode = @"";
        _debugMode = -1;
        _strategyType = AnsNoStategy;
    }
    return self;
}

#pragma mark *** public method ***

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
        self.strategyType = AnsNoStategy;
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

#pragma mark *** ANSStrategyProtocol ***

- (void)archiveStrategy {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @try {
            [NSKeyedArchiver archiveRootObject:self toFile:serverStrategyPath];
        } @catch (NSException *exception) {
            AnsError(@"Archive server stategy error: %@ !!!", exception);
        }
    });
}

+ (instancetype)unarchiveStrategy {
    @try {
        NSData *data = [[NSData alloc] initWithContentsOfFile:serverStrategyPath];
        if (data.length == 0) {
            return [[ANSServerStrategy alloc] init];
        }
        return [NSKeyedUnarchiver unarchiveObjectWithFile:serverStrategyPath];
    } @catch (NSException *exception) {
        AnsError(@"Unarchive server stategy error: %@ !!!",exception);
    }
}

- (BOOL)canUploadWithDataCount:(NSInteger)dataCount {
    //  debug模式或实时上传策略
    if (self.strategyType == AnsRealTime ||
        [ANSStrategyManager sharedManager].currentUseDebugMode != 0) {
        return YES;
    }
    //  智能策略2/3/4G状态下使用间隔发送，WIFI下实时发送
    if (self.strategyType == AnsSmart) {
        if ([[ANSTelephonyNetwork shareInstance] isCellular]) {
            //  间隔或智能策略
            if (dataCount >= self.flushBulkSize) {
                return YES;
            }
            [self upIntergerStrategy];
            return NO;
        } else if ([[ANSTelephonyNetwork shareInstance] isWIFI]) {
            return YES;
        } else {
            // 无网络
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
    if (allowDispatch && self.flushInterval > 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.flushInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ANSFlushDataNotification object:nil];
            //  发送数据上传通知
            allowDispatch = YES;
        });
        allowDispatch = NO;
    }
}

#pragma mark *** NSCoding ***

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_hashCode forKey:@"hashCode"];
    [aCoder encodeObject:_serverUrl forKey:@"serverUrl"];
    
    [aCoder encodeInteger:_strategyType forKey:@"strategyType"];
    [aCoder encodeInteger:_debugMode forKey:@"debugMode"];
    [aCoder encodeInteger:_flushInterval forKey:@"flushInterval"];
    [aCoder encodeInteger:_flushBulkSize forKey:@"flushBulkSize"];
    [aCoder encodeInteger:_maxAllowFailedCount forKey:@"maxAllowFailedCount"];
    [aCoder encodeInteger:_maxFailTryDelay forKey:@"maxFailTryDelay"];
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
