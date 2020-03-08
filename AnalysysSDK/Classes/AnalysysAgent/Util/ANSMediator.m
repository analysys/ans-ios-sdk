//
//  ANSMediator.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/21.
//  Copyright © 2019 analysys. All rights reserved.
//

#import "ANSMediator.h"

#import "NSInvocation+ANSHelper.h"

@implementation ANSMediator

+ (id)performTarget:(id)target action:(NSString *)actionName {
    return [self performTarget:target action:actionName params:nil];
}

+ (id)performTarget:(id)target action:(NSString *)actionName params:(NSArray *)parameters {
    SEL selector = NSSelectorFromString(actionName);
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    if (signature == nil) {
        //ANSDebug(@"MethodSignature failure:%@ !", actionName);
        return nil;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    invocation.selector = selector;
    
    if (parameters.count) {
        NSArray *param = [parameters copy];
        [invocation ansSetArgumentsFromArray:param];
    }
    [invocation invoke];
    id returnValue = nil;
    if (signature.methodReturnLength) {
        returnValue = [invocation ansReturnValue];
    }
    return returnValue;
}


@end


