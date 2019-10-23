//
//  ANSConsoleLog.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/5/7.
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

typedef NS_ENUM(NSInteger, AnalysysResultType) {
    AnalysysResultDefault = 0,
    AnalysysResultSetFailed, //  设置失败
    AnalysysResultNotNil, //  不能 为空
    AnalysysResultReservedKey,  //  保留字段
    AnalysysResultOutOfString, // 字符串超长
    AnalysysResultIllegalOfString, //  字符串不符合规则
    AnalysysResultTypeError, // 类型错误
    AnalysysResultPropertyValueFixed, // 属性被修改，字符串超长被截取,数组中的空字符串移除,集合元素个数超出限制被截取

    AnalysysResultSuccess ,
    AnalysysResultSetSuccess, // 设置成功
};


typedef NS_ENUM(NSUInteger, AnalysysLoggerLevel) {
    AnalysysLoggerLevelInfo = 0,
    AnalysysLoggerLevelWarning,
    AnalysysLoggerLevelError,
};

@interface ANSConsoleLog : NSObject

/** 日志类型 */
@property (nonatomic, assign) AnalysysResultType resultType;
/** 关键信息 */
@property (nonatomic, copy) NSString *keyWords;
/** 未修改值 原值 */
@property (nonatomic, strong) id value;
/** 日志备注 */
@property (nonatomic, copy) NSString *remarks;
/** 修改后值信息 */
@property (nonatomic, strong) id valueFixed;

/**
 日志信息

 @return 日志
 */
- (NSString *)messageDisplay;

@end



#define ANSLogLevel(briefLog,lvl,fmt,...)                  \
[AnalysysLogger log : YES                                  \
brief : briefLog                                           \
level : lvl                                                \
file : __FILE__                                            \
function : __PRETTY_FUNCTION__                             \
line : __LINE__                                            \
format : (fmt), ## __VA_ARGS__]

#define ANSLog(fmt,...)\
ANSLogLevel(NO,AnalysysLoggerLevelInfo,(fmt), ## __VA_ARGS__)

#define ANSWarning(fmt,...)\
ANSLogLevel(NO,AnalysysLoggerLevelWarning,(fmt), ## __VA_ARGS__)

#define ANSError(fmt,...)\
ANSLogLevel(NO,AnalysysLoggerLevelError,(fmt), ## __VA_ARGS__)

#define ANSBriefLog(fmt,...)\
ANSLogLevel(YES,AnalysysLoggerLevelInfo,(fmt), ## __VA_ARGS__)

#define ANSBriefWarning(fmt,...)\
ANSLogLevel(YES,AnalysysLoggerLevelWarning,(fmt), ## __VA_ARGS__)

#define ANSBriefError(fmt,...)\
ANSLogLevel(YES,AnalysysLoggerLevelError,(fmt), ## __VA_ARGS__)


//#define ANS_DEBUG_ENABLE

#ifdef ANS_DEBUG_ENABLE
#define AnsDebug(...) AnsDebugLog(__VA_ARGS__);
#define AnsPrint   ANSLog
#define AnsWarning ANSWarning
#define AnsError   ANSError
#else
#define AnsDebug(...);
#define AnsPrint   ANSBriefLog
#define AnsWarning ANSBriefWarning
#define AnsError   ANSBriefError
#endif


@interface AnalysysLogger : NSObject

@property (class , readonly, strong) AnalysysLogger *sharedInstance;

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
