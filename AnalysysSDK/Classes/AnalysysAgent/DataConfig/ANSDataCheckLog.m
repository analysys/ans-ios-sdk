//
//  ANSDataCheckLog.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/5/7.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSDataCheckLog.h"

static NSUInteger const ANSPrintLogLength = 30;

static inline NSString * AnsLogSring(NSString *format, ...) {
    va_list arg_list;
    va_start (arg_list, format);
    NSString *logString = [[NSString alloc] initWithFormat:format arguments:arg_list];
    va_end(arg_list);
    return [NSString stringWithFormat:@"%@", logString];
}

@implementation ANSDataCheckLog

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
    NSString *message = @"";
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
    return [message copy];
}

- (NSString *)substringText:(id)text {
    if (text == nil) {
        return @"";
    }
    if ([text isKindOfClass:NSString.class]) {
        NSString *string = (NSString*)text;
        if (string.length > ANSPrintLogLength) {
            return [NSString stringWithFormat:@"%@...",[text substringToIndex:ANSPrintLogLength]];
        }
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


