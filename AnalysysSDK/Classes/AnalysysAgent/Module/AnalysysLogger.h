//
//  AnalysysLogger.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/10/14.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

static inline void AnsDebugLog(NSString *format, ...) {
    va_list arg_list;
    va_start (arg_list, format);
    NSString *logString = [[NSString alloc] initWithFormat:format arguments:arg_list];
    va_end(arg_list);
    NSLog(@"********** [Analysys] [Debug] %@ **********", logString);
}

#define ANSLogLevel(briefLog,lvl,fmt,...)                  \
        [AnalysysLogger log : YES                          \
        brief : briefLog                                   \
        level : lvl                                        \
        file : __FILE__                                    \
        function : __PRETTY_FUNCTION__                     \
        line : __LINE__                                    \
        format : (fmt), ## __VA_ARGS__]

//  是否开启调试日志
//#define ANS_DEBUG_ENABLE

#ifdef ANS_DEBUG_ENABLE
#define ANSDebug(...) AnsDebugLog(__VA_ARGS__);
#else
#define ANSDebug(...)
#endif

#define ANSLog(fmt,...) ANSLogLevel(NO,AnalysysLoggerLevelInfo,(fmt), ## __VA_ARGS__)
#define ANSBriefLog(fmt,...) ANSLogLevel(YES,AnalysysLoggerLevelInfo,(fmt), ## __VA_ARGS__)
#define ANSBriefWarning(fmt,...) ANSLogLevel(YES,AnalysysLoggerLevelWarning,(fmt), ## __VA_ARGS__)
#define ANSBriefError(fmt,...) ANSLogLevel(YES,AnalysysLoggerLevelError,(fmt), ## __VA_ARGS__)

typedef NS_ENUM(NSUInteger, AnalysysLoggerLevel) {
    AnalysysLoggerLevelInfo = 0,
    AnalysysLoggerLevelWarning,
    AnalysysLoggerLevelError,
};

typedef NS_ENUM(NSInteger, AnalysysLogMode) {
    AnalysysLogOff = 0,
    AnalysysLogOn = 1,
};


/**
 * @class
 * 日志打印
 *
 * @abstract
 * 日志打印
 *
 * @discussion
 * 日志打印
 */
@interface AnalysysLogger : NSObject

@property (class , readonly, strong) AnalysysLogger *sharedInstance;

@property (nonatomic, assign) AnalysysLogMode logMode;

+ (BOOL)isLoggerEnabled;

+ (void)enableLog:(BOOL)enableLog;

+ (void)log:(BOOL)asynchronous
      brief:(BOOL)briefLog
      level:(NSInteger)level
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
     format:(NSString *)format, ... ;

@end


