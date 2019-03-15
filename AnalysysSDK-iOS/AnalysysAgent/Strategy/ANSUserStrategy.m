//
//  ANSUserStrategy.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/1/17.
//  Copyright © 2019 analysys. All rights reserved.
//

#import "ANSUserStrategy.h"
#import "ANSFileManager.h"
#import "ANSConsleLog.h"
#import "ANSStrategyManager.h"
#import "ANSTelephonyNetwork.h"

#define userStrategyPath [ANSFileManager filePathWithName:@"ANSUserStrategy.plist"]
static BOOL allowDispatch = YES;//  控制是否再次发起延迟策略

@implementation ANSUserStrategy

- (instancetype)init {
    self = [super init];
    if (self) {
        _debugMode = -1;
        _flushInterval = -1;
        _flushBulkSize = -1;
    }
    return self;
}

- (void)setServerUrl:(NSString *)serverUrl {
    _serverUrl = serverUrl;
    [self archiveStrategy];
}

- (void)setDebugMode:(NSInteger)debugMode {
    _debugMode = debugMode;
    [self archiveStrategy];
}

- (void)setFlushInterval:(NSInteger)flushInterval {
    _flushInterval = flushInterval;
    [self archiveStrategy];
}

- (void)setFlushBulkSize:(NSInteger)flushBulkSize {
    _flushBulkSize = flushBulkSize;
    [self archiveStrategy];
}

#pragma mark *** ANSStrategyProtocol ***

- (void)archiveStrategy {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @try {
            [NSKeyedArchiver archiveRootObject:self toFile:userStrategyPath];
        } @catch (NSException *exception) {
            AnsError(@"Archive user stategy error: %@ !!!", exception);
        }
    });
}

+ (instancetype)unarchiveStrategy {
    @try {
        NSData *data = [[NSData alloc] initWithContentsOfFile:userStrategyPath];
        if (data.length == 0) {
            return [[ANSUserStrategy alloc] init];
        }
        return [NSKeyedUnarchiver unarchiveObjectWithFile:userStrategyPath];
    } @catch (NSException *exception) {
        AnsError(@"Unarchive user stategy error: %@ !!!",exception);
    }
}

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

#pragma mark *** NSCoding ***

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_serverUrl forKey:@"serverUrl"];

    [aCoder encodeInteger:_debugMode forKey:@"debugMode"];
    [aCoder encodeInteger:_flushInterval forKey:@"flushInterval"];
    [aCoder encodeInteger:_flushBulkSize forKey:@"flushBulkSize"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _serverUrl = [coder decodeObjectForKey:@"serverUrl"];

        _debugMode = [coder decodeIntegerForKey:@"debugMode"];
        _flushInterval = [coder decodeIntegerForKey:@"flushInterval"];
        _flushBulkSize = [coder decodeIntegerForKey:@"flushBulkSize"];
    }
    return self;
}

@end
