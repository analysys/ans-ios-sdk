//
//  ANSDefaultStrategy.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/1/17.
//  Copyright © 2019 analysys. All rights reserved.
//

#import "ANSDefaultStrategy.h"
#import "ANSFileManager.h"
#import "ANSConsleLog.h"
#import "ANSStrategyManager.h"
#import "ANSTelephonyNetwork.h"

static BOOL allowDispatch = YES;//  控制是否再次发起延迟策略

@implementation ANSDefaultStrategy

- (instancetype)init {
    self = [super init];
    if (self) {
        _debugMode = 0;
        _flushInterval = 5;
        _flushBulkSize = 10;
        _maxAllowFailedCount = 3;
        _maxFailedDelay = 3600;
    }
    return self;
}

#pragma mark *** ANSStrategyProtocol ***

- (BOOL)canUploadWithDataCount:(NSInteger)dataCount {
    //  debug模式实时上传
    if ([ANSStrategyManager sharedManager].currentUseDebugMode != 0) {
        return YES;
    }
    if ([[ANSTelephonyNetwork shareInstance] isCellular]) {
        //  间隔或条数策略
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


@end
