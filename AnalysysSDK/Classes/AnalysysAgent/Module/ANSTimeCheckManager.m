//
//  ANSTimeCheckManager.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/10/31.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSTimeCheckManager.h"

#import "ANSUploadManager.h"
#import "ANSTelephonyNetwork.h"
#import "AnalysysAgentConfig.h"
#import "ANSConsoleLog.h"
#import "ANSDateUtil.h"
#import "ANSJsonUtil.h"
#import "ANSConst+private.h"

@implementation ANSTimeCheckManager {
    ANSUploadManager *_uploadManager;
    BOOL _isTimeCheckRequestFinished;  //  时间校准请求是否完成
    BOOL _isNeedTimeCheck;  // 是否需要时间校准
    NSTimeInterval _serverTimerDiff;    // 服务器与本地时间差
}

+ (instancetype)shared {
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
        _uploadManager = [[ANSUploadManager alloc] init];
        _serverTimerDiff = 0;
    }
    return self;
}

- (BOOL)timeCheckRequestIsFinished {
    if (!AnalysysConfig.allowTimeCheck) {
        return YES;
    }
    return _isTimeCheckRequestFinished;
}

- (void)requestWithServer:(NSString *)serverUrl block:(void(^)(void))block {
    if (!AnalysysConfig.allowTimeCheck) {
        return;
    }
    if (![[ANSTelephonyNetwork shareInstance] hasNetwork]) {
        self->_isTimeCheckRequestFinished = YES;
        return;
    }
    [self->_uploadManager getRequestWithServerURLStr:serverUrl parameters:nil success:^(NSURLResponse *response, NSData *responseData) {
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        NSString *string = [NSString stringWithFormat:@"%@", res.allHeaderFields[@"Date"]];
        NSDate *serverDate = [[ANSDateUtil timeCheckFormat] dateFromString:string];
        NSTimeInterval serverTimeInterval = [serverDate timeIntervalSince1970];
        NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval timerDiff = serverTimeInterval - nowTimeInterval;
        
        self->_serverTimerDiff = timerDiff;
        self->_isTimeCheckRequestFinished = YES;
        self->_isNeedTimeCheck = YES;
        
        if (fabs(timerDiff) > AnalysysConfig.maxDiffTimeInterval) {
            AnsPrint(@"收到服务器的时间：%@，本地时间：%@，时间相差：%.f 秒，数据将会进行时间校准。", [ANSDateUtil convertToLocalDate:serverDate], [ANSDateUtil convertToLocalDate:[NSDate date]], fabs(timerDiff));
        }
        block();
    } failure:^(NSError *error) {
        self->_isTimeCheckRequestFinished = YES;
        block();
    }];
}

- (NSArray *)checkDataArray:(NSArray *)dataArray {
    if (!AnalysysConfig.allowTimeCheck) {
        return [self getLogsFromArray:dataArray];
    }
    if (fabs(_serverTimerDiff) < AnalysysConfig.maxDiffTimeInterval) {
        return [self getLogsFromArray:dataArray];
    }
    if (!_isNeedTimeCheck) {
        return [self getLogsFromArray:dataArray];
    }
    NSMutableArray *uploadArray = [NSMutableArray array];
    for (NSDictionary *logInfo in dataArray) {
        NSString *logJsonString = logInfo[ANSLogJson];
        NSDictionary *logDic = [ANSJsonUtil convertToMapWithString:logJsonString];
        NSMutableDictionary *mutableLogDic = [NSMutableDictionary dictionaryWithDictionary:logDic];
        NSString *logNew = logInfo[ANSLogOldOrNew];
        if ([logNew isEqualToString:@"1"]) {
            //  仅更改本次启动数据，历史数据不作处理
            long long xwhen = [mutableLogDic[ANSXwhen] longLongValue] + _serverTimerDiff*1000;
            mutableLogDic[ANSXwhen] = [NSNumber numberWithLongLong:xwhen];
            NSMutableDictionary *xcontext = mutableLogDic[ANSXcontext];
            if ([xcontext.allKeys containsObject:ANSTimeCalibrated]) {
                xcontext[ANSTimeCalibrated] = [NSNumber numberWithBool:YES];
            }
        }
        [uploadArray addObject:[ANSJsonUtil convertToStringWithObject:mutableLogDic]];
    }
    return uploadArray;
}

- (NSArray *)getLogsFromArray:(NSArray *)dataArray {
    NSMutableArray *logs = [NSMutableArray array];
    for (NSDictionary *dataInfo in dataArray) {
        [logs addObject:dataInfo[ANSLogJson]];
    }
    return [NSArray arrayWithArray:logs];
}

@end
