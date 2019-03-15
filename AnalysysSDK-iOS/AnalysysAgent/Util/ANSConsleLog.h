//
//  ANSConsleLog.h
//  AnalysysAgent
//
//  Created by SoDo on 2018/11/15.
//  Copyright © 2018 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANSStrategyManager.h"

static inline void AnsLog(NSString *logType, NSString *format, ...) {
    if ([ANSStrategyManager sharedManager].currentUseDebugMode != 0) {
        __block va_list arg_list;
        va_start (arg_list, format);
        NSString *logString = [[NSString alloc] initWithFormat:format arguments:arg_list];
        va_end(arg_list);
        if ([logType isEqualToString:@"Debug"]) {
            NSLog(@"********** [Analysys] [%@] %@ **********", logType, logString);
        } else {
            NSLog(@"[Analysys] [%@] %@", logType, logString);
        }
    }
}

#define AnsPrint(...) AnsLog(@"Log", __VA_ARGS__)
#define AnsWarning(...) AnsLog(@"Warning", __VA_ARGS__)
#define AnsError(...) AnsLog(@"Error", __VA_ARGS__)



static inline void AnsDebugLog(NSString *format, ...) {
    __block va_list arg_list;
    va_start (arg_list, format);
    NSString *logString = [[NSString alloc] initWithFormat:format arguments:arg_list];
    va_end(arg_list);
    NSLog(@"********** [Analysys] [Debug] %@ **********", logString);
}

//#define ANS_DEBUG_ENABLE

#ifdef ANS_DEBUG_ENABLE
#define AnsDebug(...) AnsDebugLog(__VA_ARGS__)
#else
#define AnsDebug(...);
#endif




/**
 * @class
 * ANSConsleLog
 *
 * @abstract
 * 日志工具
 *
 * @discussion
 * 日志打印
 */

@interface ANSConsleLog : NSObject

/**
 接口调用成功日志

 @param identifier 标识
 @param value 传入值
 */
+ (void)logSuccess:(NSString *)identifier value:(id)value;

/**
 用户警告日志

 @param identifier 标识
 @param value 日志显示值
 @param desc 警告信息
 */
+ (void)logWarning:(NSString *)identifier value:(id)value detail:(NSString *)desc;

+ (void)logWarningDetail:(NSString *)desc;


@end


