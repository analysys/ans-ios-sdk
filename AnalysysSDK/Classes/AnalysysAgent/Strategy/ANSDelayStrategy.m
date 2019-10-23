//
//  ANSDelayStrategy.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/1/18.
//  Copyright © 2019 analysys. All rights reserved.
//

#import "ANSDelayStrategy.h"
#import "ANSFileManager.h"
#import "ANSConsoleLog.h"
#import "ANSStrategyManager.h"
#import "ANSServerStrategy.h"

#define ANS_DELAY_STRATEGY_PATH [ANSFileManager filePathWithName:@"ANSDelayStrategy.plist"]

static BOOL ANSCanSendData = YES;//  控制是否再次发起延迟策略

@implementation ANSDelayStrategy

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentFailedCount = 0;
        _failDelayDate = nil;
    }
    return self;
}


#pragma mark - ANSStrategyProtocol

- (void)archiveStrategy {
    @try {
        [NSKeyedArchiver archiveRootObject:self toFile:ANS_DELAY_STRATEGY_PATH];
    } @catch (NSException *exception) {
        
    }
}

+ (instancetype)unarchiveStrategy {
    @try {
        NSData *data = [[NSData alloc] initWithContentsOfFile:ANS_DELAY_STRATEGY_PATH];
        if (data.length == 0) {
            return [[ANSDelayStrategy alloc] init];
        }
        return [NSKeyedUnarchiver unarchiveObjectWithFile:ANS_DELAY_STRATEGY_PATH];
    } @catch (NSException *exception) {
        return [[ANSDelayStrategy alloc] init];;
    }
}

- (BOOL)canUploadWithDataCount:(NSInteger)dataCount {
    if (!ANSCanSendData) {
        //  正在上传
        return NO;
    }
    if (!self.failDelayDate) {
        return YES;
    }
    if ([self currentMaxFailedDelay] == -1) {
        return YES;
    }
    //  达到最大失败次数
    NSTimeInterval failDelay = ceil([[NSDate date] timeIntervalSinceDate:self.failDelayDate]);
    NSTimeInterval delayInterval = [self currentMaxFailedDelay] - failDelay;
    return [self canExcuteUpload:delayInterval];
}

/** 是否可上传数据 */
- (BOOL)canExcuteUpload:(double)delayInterval {
    if (ANSCanSendData && delayInterval > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ANSFlushDataNotification object:nil];
            //  发送数据上传通知
            ANSCanSendData = YES;
        });
        AnsWarning(@"*********** Upload failure times: %ld, after %.f seconds to upload again! ***********",_currentFailedCount, delayInterval);
        ANSCanSendData = NO;
        return NO;
    }
    //  超过最大失败延迟
    if (delayInterval <= 0) {
        [[ANSStrategyManager sharedManager] resetDelayStrategyFailedTry];
        return YES;
    }
    return NO;
}

#pragma mark - private method

- (NSInteger)currentMaxFailedDelay {
    NSInteger serverFailDelay = [ANSStrategyManager sharedManager].serverStrategy.maxFailTryDelay;
    if (serverFailDelay > 0) {
        return serverFailDelay;
    }
    return -1;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    @try {
        [aCoder encodeObject:_failDelayDate forKey:@"failDelayDate"];
        [aCoder encodeInteger:_currentFailedCount forKey:@"currentFailedCount"];
    } @catch (NSException *exception) {
        
    }
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _failDelayDate = [coder decodeObjectForKey:@"failDelayDate"];
        _currentFailedCount = [coder decodeIntegerForKey:@"currentFailedCount"];
    }
    return self;
}

@end
