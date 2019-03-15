//
//  ANSDelayStrategy.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/1/18.
//  Copyright © 2019 analysys. All rights reserved.
//

#import "ANSDelayStrategy.h"
#import "ANSFileManager.h"
#import "ANSConsleLog.h"
#import "ANSStrategyManager.h"

#define DelayStrategyPath [ANSFileManager filePathWithName:@"ANSDelayStrategy.plist"]

static BOOL allowDispatch = YES;//  控制是否再次发起延迟策略

@implementation ANSDelayStrategy

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentFailedCount = 0;
        _failDelayDate = nil;
    }
    return self;
}

#pragma mark *** public method ***

- (void)increaseFailCount {
    //  取消队列中上传任务
    [[NSNotificationCenter defaultCenter] postNotificationName:ANSCancelOperationQueueNotification object:nil];
    
    _currentFailedCount ++;
    
    //  达到最大失败次数 执行延迟
    if (_currentFailedCount == [ANSStrategyManager sharedManager].currentUseMaxAllowFailedCount+1) {
        self.failDelayDate = [NSDate date];
        [self canUploadWithDataCount:0];
    }
    
    //  普通上传失败重传
    if (_currentFailedCount < [ANSStrategyManager sharedManager].currentUseMaxAllowFailedCount+1) {
        NSInteger failedNextInterval = 5 + arc4random() % 10;
        [self canExcuteUpload:failedNextInterval];
    }
    
    [self archiveStrategy];
}

- (void)resetFailedTry {
    self.currentFailedCount = 0;
    self.failDelayDate = nil;
    [self archiveStrategy];
}

#pragma mark *** ANSStrategyProtocol ***

- (void)archiveStrategy {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @try {
            [NSKeyedArchiver archiveRootObject:self toFile:DelayStrategyPath];
        } @catch (NSException *exception) {
            AnsError(@"Archive delay stategy error: %@ !!!", exception);
        }
    });
}

+ (instancetype)unarchiveStrategy {
    @try {
        NSData *data = [[NSData alloc] initWithContentsOfFile:DelayStrategyPath];
        if (data.length == 0) {
            return [[ANSDelayStrategy alloc] init];
        }
        return [NSKeyedUnarchiver unarchiveObjectWithFile:DelayStrategyPath];
    } @catch (NSException *exception) {
        AnsError(@"Unarchive delay stategy error: %@ !!!",exception);
    }
}

- (BOOL)canUploadWithDataCount:(NSInteger)dataCount {
    if (!allowDispatch) {
        //  正在上传
        return NO;
    }
    if (!self.failDelayDate) {
        return YES;
    }
    //  达到最大失败次数
    NSTimeInterval failDelay = ceil([[NSDate date] timeIntervalSinceDate:self.failDelayDate]);
    NSTimeInterval delayInterval = [self currentMaxFailedDelay] - failDelay;
    return [self canExcuteUpload:delayInterval];
}

/** 是否可上传数据 */
- (BOOL)canExcuteUpload:(double)delayInterval {
    if (allowDispatch && delayInterval > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ANSFlushDataNotification object:nil];
            //  发送数据上传通知
            allowDispatch = YES;
        });
        AnsWarning(@"当前上传失败%ld次，%.f秒后再次上传!",_currentFailedCount, delayInterval);
        allowDispatch = NO;
        return NO;
    }
    //  超过最大失败延迟
    if (delayInterval <= 0) {
        [self resetFailedTry];
        return YES;
    }
    return NO;
}

#pragma mark *** private method ***

- (NSInteger)currentMaxFailedDelay {
    NSInteger serverFailDelay = [ANSStrategyManager sharedManager].serverStrategy.maxFailTryDelay;
    if (serverFailDelay > 0) {
        return serverFailDelay;
    }
    return [ANSStrategyManager sharedManager].defaultStrategy.maxFailedDelay;
}

#pragma mark *** NSCoding ***

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_failDelayDate forKey:@"failDelayDate"];
    
    [aCoder encodeInteger:_currentFailedCount forKey:@"currentFailedCount"];
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
