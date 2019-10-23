//
//  ANSUserStrategy.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/1/17.
//  Copyright © 2019 analysys. All rights reserved.
//

#import "ANSUserStrategy.h"
#import "ANSFileManager.h"
#import "ANSStrategyManager.h"


#define ANS_USER_STRATEGY_PATH [ANSFileManager filePathWithName:@"ANSUserStrategy.plist"]
static BOOL ANSCanSendData = YES;//  控制是否再次发起延迟策略

@implementation ANSUserStrategy

- (instancetype)init {
    self = [super init];
    if (self) {
        _debugMode = -1;
        _flushInterval = 0;
        _flushBulkSize = 0;
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

- (void)setFlushInterval:(NSUInteger)flushInterval {
    _flushInterval = flushInterval;
    [self archiveStrategy];
}

- (void)setFlushBulkSize:(NSUInteger)flushBulkSize {
    _flushBulkSize = flushBulkSize;
    [self archiveStrategy];
}

#pragma mark - ANSStrategyProtocol

- (void)archiveStrategy {
    @try {
        [NSKeyedArchiver archiveRootObject:self toFile:ANS_USER_STRATEGY_PATH];
    } @catch (NSException *exception) {
        
    }
}

+ (instancetype)unarchiveStrategy {
    @try {
        NSData *data = [[NSData alloc] initWithContentsOfFile:ANS_USER_STRATEGY_PATH];
        if (data.length == 0) {
            return [[ANSUserStrategy alloc] init];
        }
        return [NSKeyedUnarchiver unarchiveObjectWithFile:ANS_USER_STRATEGY_PATH];
    } @catch (NSException *exception) {
        return [[ANSUserStrategy alloc] init];
    }
}

- (BOOL)canUploadWithDataCount:(NSInteger)dataCount {
    //  debug模式实时上传
    if ([ANSStrategyManager sharedManager].currentUseDebugMode != 0) {
        return YES;
    }
    
    //  间隔或条数策略
    if (dataCount >= self.flushBulkSize) {
        return YES;
    }
    [self upIntergerStrategy];
    return NO;

}

//  间隔发送
- (void)upIntergerStrategy {
    if (ANSCanSendData && self.flushInterval > 1) {
        ANSCanSendData = NO;
        
        if ([[NSDate date] timeIntervalSince1970] - ANSTimeInterval > self.flushInterval) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ANSFlushDataNotification object:nil];
            ANSTimeInterval = [[NSDate date] timeIntervalSince1970];
            ANSCanSendData = YES;
        } else {
            NSInteger interval = self.flushInterval - fabs(([[NSDate date] timeIntervalSince1970] - ANSTimeInterval));
            ANSTimeInterval = [[NSDate date] timeIntervalSince1970];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:ANSFlushDataNotification object:nil];
                ANSCanSendData = YES;
            });
        }
   
    }
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    @try {
        [aCoder encodeObject:_serverUrl forKey:@"serverUrl"];
        [aCoder encodeInteger:_debugMode forKey:@"debugMode"];
        [aCoder encodeInteger:_flushInterval forKey:@"flushInterval"];
        [aCoder encodeInteger:_flushBulkSize forKey:@"flushBulkSize"];
    } @catch (NSException *exception) {
        
    }
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
