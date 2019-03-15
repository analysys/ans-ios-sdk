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

+ (void)AnsExchangeOriginalClass:(Class)originalClass
                     originalSel:(SEL)originalSel
                   replacedClass:(Class)replacedClass
                     replacedSel:(SEL)replacedSel {

    Method originalMethod = class_getInstanceMethod(originalClass, originalSel);
    Method replacedMethod = class_getInstanceMethod(replacedClass, replacedSel);
    
    IMP replacedMethodIMP = method_getImplementation(replacedMethod);
    BOOL didAddMethod = class_addMethod(originalClass,
                                        replacedSel,
                                        replacedMethodIMP,
                                        method_getTypeEncoding(replacedMethod));
    if (didAddMethod) {
        Method newMethod = class_getInstanceMethod(originalClass, replacedSel);
        method_exchangeImplementations(originalMethod, newMethod);
    } else {
        method_exchangeImplementations(originalMethod, replacedMethod);
    }
}




@end
