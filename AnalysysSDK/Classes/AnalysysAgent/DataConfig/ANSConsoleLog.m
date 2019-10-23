//
//  ANS_m
//  AnalysysAgent
//
//  Created by SoDo on 2019/5/7.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSConsoleLog.h"
#import "AnalysysSDK.h"

static NSUInteger const ANSPrintLogLength = 30;

static inline NSString * AnsLogSring(NSString *format, ...) {
    va_list arg_list;
    va_start (arg_list, format);
    NSString *logString = [[NSString alloc] initWithFormat:format arguments:arg_list];
    va_end(arg_list);
    return [NSString stringWithFormat:@"%@", logString];
}

@implementation ANSConsoleLog

- (instancetype)init {
    if (self = [super init]) {
        _resultType = AnalysysResultDefault;
        _keyWords = nil;
        _value = nil;
        _remarks = nil;
        _valueFixed = nil;
    }
    return self;
}

- (NSString *)messageDisplay {
    NSString * message = nil;
    if (self.resultType == AnalysysResultDefault) {
        message = AnsLogSring(@"%@",self.remarks);
    } else if (self.resultType == AnalysysResultSetSuccess) {
        if (self.value == nil) {
            message = AnsLogSring(@"set success.");
        } else if ([self.value isKindOfClass:NSString.class]) {
            message = AnsLogSring(@"(%@): set success.", [self substringText:self.value]);
        } else {
            message = AnsLogSring(@"(%@): set success.", self.value);
        }
    } else if (self.resultType == AnalysysResultSetFailed) {
        message = AnsLogSring(@"(%@): set failed, %@!",[self substringText:self.value], self.remarks);
    } else if (self.resultType == AnalysysResultNotNil) {
        message = AnsLogSring(@"'%@' can not be empty.", self.keyWords);
    } else if (self.resultType == AnalysysResultReservedKey) {
        message = AnsLogSring(@"%@ is reserved key.", self.value);
    } else if (self.resultType == AnalysysResultOutOfString) {
        message = AnsLogSring(@"The length of string '%@' need to be %@.", [self substringText:[self.value description]], self.keyWords);
    } else if (self.resultType == AnalysysResultTypeError) {
        message = AnsLogSring(@"Value type invalid, support type: %@ \ncurrent value: %@ \ncurrent type: %@", self.keyWords, self.value, [self.value class]);
    } else if (self.resultType == AnalysysResultIllegalOfString) {
        message = AnsLogSring(@"(%@) is invalid. The string need to begin with [a-zA-Z] and only contain [a-zA-Z0-9_].", [self substringText:[self.value description]]);
    } else if (self.resultType == AnalysysResultPropertyValueFixed) {
        message = AnsLogSring(@"(%@) is invalid.", [self substringText:[self.value description]]);
    }
    return message;
}

- (NSString *)substringText:(NSString *)text {
    if (text.length > ANSPrintLogLength) {
        return [NSString stringWithFormat:@"%@...",[text substringToIndex:ANSPrintLogLength]];
    }
    return text;
}

- (void)dealloc {
    _valueFixed = nil;
    _value = nil;
    _keyWords = nil;
    _remarks = nil;
}

@end

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif


#import <Foundation/Foundation.h>
#import "ANSConsoleLog.h"

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
        if ([AnalysysSDK sharedManager].debugMode != AnalysysDebugOff) {
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
