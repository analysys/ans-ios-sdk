//
//  ANSSessionManager.m
//  AnalysysAgent
//
//  Created by SoDo on 2018/12/5.
//  Copyright © 2018 analysys. All rights reserved.
//

#import "ANSSession.h"
#import "NSString+ANSMD5.h"

//  页面切换session时长/秒
static const NSTimeInterval pageInterval = 30.0;

@implementation ANSSession {
    NSDate *_lastPageStartDate; //  上一页面开始时间，用于跨天session切换
    NSDate *_lastPageEndDate; //  上一页面结束时间，用于30秒session切换
    BOOL _isWakeUp; //  本次是否被唤醒
    BOOL _isSameDay;  //  上一页面开始与当前页面打开时间是否同一天
    NSDateFormatter *_dateFmt; // 手机对应时区的时间格式化
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWakedUpNotification:) name:@"ANSAppWakedUpNotification" object:nil];
        _dateFmt = [[NSDateFormatter alloc] init];
        _dateFmt.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS ZZZZ";
        _dateFmt.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    }
    return self;
}

/** 设置session */
- (void)generateSessionId {
    //  初始化session
    if (_sessionId == nil) {
        _sessionId = [self localSession];
        if (_sessionId == nil) {
            _sessionId = [self createSessionId];
            return;
        }
    }
    if (_lastPageEndDate == nil) {
        _lastPageEndDate = [self lastPageDisappearDate];
    }
    if (_lastPageEndDate == nil && _sessionId) {
        return;
    }
    //NSAssert(_pageDate != nil, @"_pageDate 不可能为空");
    //  页面事件跨天
    _isSameDay = [self isSameDayWithDate:_lastPageStartDate];
    if (!_isSameDay) {
        _sessionId = [self createSessionId];
        return;
    }
    //  App吊起
    if (_isWakeUp) {
        _sessionId = [self createSessionId];
        return;
    }
    //  页面事件超过30秒
    if ([self isPageChangedWithDate:_lastPageEndDate]) {
        _sessionId = [self createSessionId];
        return;
    }
    //NSAssert(_sessionId != nil, @"此处session不能为空");
}

/** 更新页面开始时间 */
- (void)updatePageAppearDate {
    NSDate *now = [NSDate date];
    if (_lastPageStartDate) {
        if (!_isSameDay) {
            _lastPageStartDate = now;
            [self saveLastPageAppearDate:now];
        }
        return;
    }
    _lastPageStartDate = [self lastPageAppearDate];
    if (_lastPageStartDate == nil) {
        _lastPageStartDate = now;
        [self saveLastPageAppearDate:now];
    }
}

/** 更新页面结束时间 */
- (void)updatePageDisappearDate {
    _lastPageEndDate = [NSDate date];
    [self saveLastPageDisappearDate:_lastPageEndDate];
}

- (NSString *)sessionId {
    return [_sessionId copy];
}

#pragma mark *** NSNotification ***

/** App被唤醒重置session */
- (void)appWakedUpNotification:(NSNotification *)notification {
    _isWakeUp = YES;
    [self generateSessionId];
    _isWakeUp = NO;
}

#pragma mark *** private method ***

/** session标识 */
- (NSString *)createSessionId {
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *str = [NSString stringWithFormat:@"iOS%@%u",[NSNumber numberWithLongLong:nowtime], arc4random()%1000000];
    NSString *sessionId = [str AnsMD5ToUpper16Bit];
    
    // 存储当前session
    [self saveSession:sessionId];

    return sessionId;
}

/** 传入date与当前时间是否同一天 */
- (BOOL)isSameDayWithDate:(NSDate *)eventDate {
    if (!eventDate) {
        return YES;
    }
    NSString *eventDay = [_dateFmt stringFromDate:eventDate];;
    NSString *today = [_dateFmt stringFromDate:[NSDate date]];
    BOOL compareResult = [[eventDay substringToIndex:10] isEqualToString:[today substringToIndex:10]];
    return compareResult;
}

/** 页面切换是否大于30秒 */
- (BOOL)isPageChangedWithDate:(NSDate *)pageDate {
    NSDate *systemZoneDate = [NSDate date];
    NSTimeInterval interval = [systemZoneDate timeIntervalSinceDate:pageDate];
    return interval > pageInterval;
}

#pragma mark *** 存储 ***

/** 会话session */
- (void)saveSession:(NSString *)sessionId {
    [self saveUserDefaultWithKey:@"AnalysysSession" value:sessionId];
}

- (NSString *)localSession {
    return [self userDefaultValueWithKey:@"AnalysysSession"];
}

/** 上一页面展示时间 */
- (void)saveLastPageAppearDate:(NSDate *)date {
    [self saveUserDefaultWithKey:@"AnalysysPageAppearDate" value:date];
}

- (NSDate *)lastPageAppearDate {
    return [self userDefaultValueWithKey:@"AnalysysPageAppearDate"];
}

/** 上一页面结束时间 */
- (void)saveLastPageDisappearDate:(NSDate *)date {
    [self saveUserDefaultWithKey:@"AnalysysPageDisappearDate" value:date];
}

- (NSDate *)lastPageDisappearDate {
    return [self userDefaultValueWithKey:@"AnalysysPageDisappearDate"];
}

- (void)saveUserDefaultWithKey:(NSString *)key value:(id)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}

- (id)userDefaultValueWithKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:key];
}


@end
