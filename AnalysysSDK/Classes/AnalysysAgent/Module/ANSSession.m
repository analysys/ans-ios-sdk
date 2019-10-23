//
//  ANSSessionManager.m
//  AnalysysAgent
//
//  Created by SoDo on 2018/12/5.
//  Copyright © 2018 analysys. All rights reserved.
//

#import "ANSSession.h"
#import "AnalysysSDK.h"
#import "NSString+ANSMD5.h"
#import "ANSFileManager.h"

//  页面切换session时长/秒
static const NSTimeInterval ANSSessionInterval = 30.0;

@implementation ANSSession {
    NSDate *_lastPageStartDate; //  上一页面开始时间，用于跨天session切换
    NSDate *_lastPageEndDate; //  上一页面结束时间，用于30秒session切换
    BOOL _isWakeUp; //  本次是否被唤醒
}

+ (instancetype)shareInstance {
    static id singleInstance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        singleInstance = [[self alloc] init];
    });
    return singleInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _sessionId = [self localSession];
        _lastPageEndDate = [self lastPageDisappearDate];
        _lastPageStartDate = [self lastPageAppearDate];
        if (!_sessionId || !_lastPageEndDate || !_lastPageStartDate
            || ![_lastPageEndDate isKindOfClass:NSDate.class]
            || ![_lastPageStartDate isKindOfClass:NSDate.class]) {
            [self resetSession];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWakedUpNotification:) name:@"ANSAppWakedUpNotification" object:nil];
    }
    return self;
}

/** 设置session */
- (void)generateSessionId {
    if (![self isSameDayWithDate:_lastPageStartDate]) {
        //  页面事件跨天
        [self resetSession];
    } else if ([self isPageChangedWithDate:_lastPageEndDate]) {
        //  页面事件超过30秒
        [self resetSession];
    } else if (_isWakeUp) {
        //  App调起
        [self resetSession];
    }
}

/** 重置session */
- (void)resetSession {
    [self updatePageAppearDate];
    [self updatePageDisappearDate];
    [self createSessionId];
}

/** 更新页面开始时间 */
- (void)updatePageAppearDate {
    _lastPageStartDate = [NSDate date];
    [self saveLastPageAppearDate:_lastPageStartDate];
}

/** 更新页面结束时间 */
- (void)updatePageDisappearDate {
    _lastPageEndDate = [NSDate date];
    [self saveLastPageDisappearDate:_lastPageEndDate];
}

- (NSString *)sessionId {
    return [_sessionId copy];
}

#pragma mark - NSNotification

/** App被唤醒重置session */
- (void)appWakedUpNotification:(NSNotification *)notification {
    [[AnalysysSDK sharedManager] dispatchOnSerialQueue:^{
        self->_isWakeUp = YES;
        [self createSessionId];
        self->_isWakeUp = NO;
    }];
}

#pragma mark - private method

/** session标识 */
- (void)createSessionId {
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *str = [NSString stringWithFormat:@"iOS%@%u",[NSNumber numberWithLongLong:nowtime], arc4random()%1000000];
    NSString *sessionId = [str AnsMD5ToUpper16Bit];
    _sessionId = sessionId;
    [self saveSession:_sessionId];
}

/** 传入date与当前时间是否同一天 */
- (BOOL)isSameDayWithDate:(NSDate *)eventDate {
    return [[NSCalendar currentCalendar] isDateInToday:eventDate];
}

/** 页面切换是否大于30秒 */
- (BOOL)isPageChangedWithDate:(NSDate *)pageDate {
    NSDate *systemZoneDate = [NSDate date];
    NSTimeInterval interval = [systemZoneDate timeIntervalSinceDate:pageDate];
    return interval > ANSSessionInterval;
}

#pragma mark - 存储

/** 会话session */
- (void)saveSession:(NSString *)sessionId {
    [ANSFileManager saveUserDefaultWithKey:@"AnalysysSession" value:sessionId];
}

- (NSString *)localSession {
    return [ANSFileManager userDefaultValueWithKey:@"AnalysysSession"];
}

/** 上一页面展示时间 */
- (void)saveLastPageAppearDate:(NSDate *)date {
    [ANSFileManager saveUserDefaultWithKey:@"AnalysysPageAppearDate" value:date];
}

- (NSDate *)lastPageAppearDate {
    return [ANSFileManager userDefaultValueWithKey:@"AnalysysPageAppearDate"];
}

/** 上一页面结束时间 */
- (void)saveLastPageDisappearDate:(NSDate *)date {
    [ANSFileManager saveUserDefaultWithKey:@"AnalysysPageDisappearDate" value:date];
}

- (NSDate *)lastPageDisappearDate {
    return [ANSFileManager userDefaultValueWithKey:@"AnalysysPageDisappearDate"];
}


@end
