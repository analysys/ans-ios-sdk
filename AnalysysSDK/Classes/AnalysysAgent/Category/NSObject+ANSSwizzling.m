//
//  NSObject+ANSSwizzling.m
//  AnalysysAgent
//
//  Created by analysys on 2017/2/22.
//  Copyright © 2017年 Analysys. All rights reserved.
//

#import "NSObject+ANSSwizzling.h"

#import <objc/runtime.h>

@implementation NSObject (ANSSwizzling)

+ (void)AnsExchangeOriginalSel:(SEL)originalSel replacedSel:(SEL)replacedSel {

    Method originalMethod = class_getInstanceMethod(self, originalSel);
    Method replacedMethod = class_getInstanceMethod(self, replacedSel);
    
    IMP replacedMethodIMP = method_getImplementation(replacedMethod);
    BOOL didAddMethod = class_addMethod(self,
                                        originalSel,
                                        replacedMethodIMP,
                                        method_getTypeEncoding(replacedMethod));
    if (didAddMethod) {
        Method newMethod = class_getInstanceMethod(self, replacedSel);
        method_exchangeImplementations(originalMethod, newMethod);
    } else {
        method_exchangeImplementations(originalMethod, replacedMethod);
    }
}

@end
