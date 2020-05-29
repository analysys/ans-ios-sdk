//
//  AnalysysLogger.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/10/14.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif


#import <Foundation/Foundation.h>
#import "AnalysysLogger.h"

static BOOL __enableLog__ ;
static dispatch_queue_t __logQueue__ ;

@implementation AnalysysLogger

+ (void)initialize {
    __enableLog__ = YES;
    __logQueue__ = dispatch_queue_create("com.analysys.log", DISPATCH_QUEUE_SERIAL);
}

+ (BOOL)isLoggerEnabled {
    __block BOOL enable = NO;
    dispatch_sync(__logQueue__, ^{
        enable = __enableLog__;
    });
    return enable;
}

+ (void)enableLog:(BOOL)enableLog {
    dispatch_async(__logQueue__, ^{
        __enableLog__ = enableLog;
    });
}

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)log:(BOOL)asynchronous
      brief:(BOOL)briefLog
      level:(NSInteger)level
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
     format:(NSString *)format, ... {
    @try {
        if ([[self sharedInstance] logMode] != AnalysysLogOff) {
            va_list args;
            va_start(args, format);
            NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
            va_end(args);
            [self.sharedInstance log:asynchronous brief:briefLog message:message level:level file:file function:function line:line];
        }
    } @catch(NSException *e) {
        
    }
}

- (void)log:(BOOL)asynchronous
      brief:(BOOL)briefLog
    message:(NSString *)message
      level:(NSInteger)level
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line {
    @try {
        NSString *logMessage = nil;
        if (briefLog) {
            logMessage = [[NSString alloc] initWithFormat:@"[Analysys][%@] %@\n", [self descriptionForLevel:level], message];
        } else {
//            logMessage = [[NSString alloc] initWithFormat:@"[Analysys][%@]  %s [line %lu]    %s \n%@\n", [self descriptionForLevel:level], function, (unsigned long)line, [@"" UTF8String], message];
            logMessage = [[NSString alloc] initWithFormat:@"[Analysys][%@] %@ %@\n", [self descriptionForLevel:level], [self getFuncString:function], message];
        }
        NSLog(@"%@",logMessage);
    } @catch(NSException *e) {
        
    }
}

- (NSString *)descriptionForLevel:(AnalysysLoggerLevel)level {
    NSString *desc = nil;
    switch (level) {
        case AnalysysLoggerLevelInfo:
            desc = @"Log";
            break;
        case AnalysysLoggerLevelWarning:
            desc = @"Warning";
            break;
        case AnalysysLoggerLevelError:
            desc = @"Error";
            break;
        default:
            desc = @"Unknow";
            break;
    }
    return desc;
}

- (NSString *)getFuncString:(const char *)function {
    NSString *funcStr = [NSString stringWithUTF8String:function];
    NSRange range1 = [funcStr rangeOfString:@" "];
    NSRange range2 = [funcStr rangeOfString:@"]"];
    if (range1.location != NSNotFound &&
        range2.location != NSNotFound) {
        NSRange range = NSMakeRange(range1.location+1, (range2.location - range1.location - 1));
        funcStr = [funcStr substringWithRange:range];
    }
    return funcStr;
}

- (void)dealloc {
    
}

@end
