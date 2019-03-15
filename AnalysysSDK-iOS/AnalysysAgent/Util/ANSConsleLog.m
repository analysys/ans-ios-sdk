//
//  ANSConsleLog.m
//  AnalysysAgent
//
//  Created by SoDo on 2018/11/15.
//  Copyright © 2018 analysys. All rights reserved.
//

#import "ANSConsleLog.h"

@implementation ANSConsleLog

+ (void)logSuccess:(NSString *)identifier value:(id)value {
    if (identifier.length == 0) {
        AnsPrint(@"%@.",value);
        return;
    }
    if (value == nil) {
        AnsPrint(@"%@: set success.",identifier);
    } else {
        if ([value isKindOfClass:[NSString class]]) {
            value = [ANSConsleLog substringText:value];
        }
        AnsPrint(@"%@(%@): set success.",identifier, value);
    }
}

+ (void)logWarning:(NSString *)identifier value:(id)value detail:(NSString *)desc {
    if (identifier.length == 0) {
        if ([value isKindOfClass:[NSString class]]) {
            value = [ANSConsleLog substringText:value];
            AnsWarning(@"(%@):%@!", value, desc);
        } else {
            AnsWarning(@"%@!", desc);
        }
        return;
    }
    
    if (value == nil) {
        if (desc) {
            AnsWarning(@"%@: set failed, %@!", identifier, desc);
        } else {
            AnsWarning(@"%@: set failed!", identifier);
        }
    } else {
        if ([value isKindOfClass:[NSString class]]) {
            value = [ANSConsleLog substringText:value];
        }
        if (desc) {
            AnsWarning(@"%@(%@): set failed, %@!", identifier, value, desc);
        } else {
            AnsWarning(@"%@(%@): set failed!", identifier, value);
        }
    }
}

+ (void)logWarningDetail:(NSString *)desc {
    [self logWarning:nil value:nil detail:desc];
}

+ (NSString *)substringText:(NSString *)text {
    if (text.length > 20) {
        return [NSString stringWithFormat:@"%@...",[text substringToIndex:20]];
    }
    return text;
}

@end
