//
//  ANSSwizzler.m
//  AnalysysAgent
//
//  Created by analysys on 2018/2/6.
//  Copyright © 2018年 analysys. All rights reserved.
//


#import <objc/runtime.h>

#import "ANSSwizzler.h"
#import "AnalysysLogger.h"
#import <UIKit/UIKit.h>

@implementation ANSSwizzler

+ (BOOL)isLocallyDefinedMethod:(Method)aMethod onClass:(Class)aClass {
    uint count;
    BOOL isLocal = NO;
    Method *methods = class_copyMethodList(aClass, &count);
    for (NSUInteger i = 0; i < count; i++) {
        if (aMethod == methods[i]) {
            isLocal = YES;
            break;
        }
    }
    free(methods);
    return isLocal;
}

extern IMP getSwizzleIMPBySELName (NSString * name);
extern ANSSwizzle * __strong *getSwizzleByName (NSString * name);

+ (void)swizzleSelector:(SEL)aSelector
                onClass:(Class)aClass
              withBlock:(swizzleBlock)aBlock
                  named:(NSString *)aName {
    [self swizzleSelector:aSelector
                  onClass:aClass
                withBlock:aBlock
                    named:aName
                    order:AnalysysSwizzleOrderAfter];
}

+ (void)swizzleSelector:(SEL)aSelector
                onClass:(Class)aClass
              withBlock:(swizzleBlock)aBlock
                  named:(NSString *)aName
                  order:(AnalysysSwizzleOrder)order {
    if (!aSelector || !aClass || ! aBlock || !aName) {
        return;
    }
    Method aMethod = class_getInstanceMethod(aClass,aSelector);
    if (!aMethod) {
        ANSBriefError(@"Cannot find method for %@ on %@", NSStringFromSelector(aSelector), NSStringFromClass(aClass));
        return;
    }
    IMP aSwizzleMethod = getSwizzleIMPBySELName(NSStringFromSelector(aSelector));
    ANSSwizzle * __strong * swizzle = getSwizzleByName(NSStringFromSelector(aSelector));
    if (!aSwizzleMethod || !swizzle) {
        return;
    }
    BOOL isLocal = [self isLocallyDefinedMethod:aMethod onClass:aClass];
    if (isLocal) {
        if (!*swizzle) {
            IMP originalMethod = method_getImplementation(aMethod);
            method_setImplementation(aMethod, aSwizzleMethod);
            *swizzle = [[ANSSwizzle alloc] initWithBlock:aBlock named:aName forClass:aClass selector:aSelector originalMethod:originalMethod order:order];
        } else {
            [(*swizzle).blocks setObject:aBlock forKey:aName];
        }
    } else {
        IMP originalMethod = *swizzle ? (*swizzle).originalMethod : method_getImplementation(aMethod);
        
        // Add the swizzle as a new local method on the class.
        if (!class_addMethod(aClass, aSelector, aSwizzleMethod, method_getTypeEncoding(aMethod))) {
            ANSDebug(@"SwizzleException:Could not add swizzled for %@::%@, even though it didn't already exist locally", NSStringFromClass(aClass), NSStringFromSelector(aSelector));
            return;
        }
        // Now re-get the Method, it should be the one we just added.
        Method newMethod = class_getInstanceMethod(aClass, aSelector);
        if (aMethod == newMethod) {
            ANSDebug(@"SwizzleException:Newly added method for %@::%@ was the same as the old method", NSStringFromClass(aClass), NSStringFromSelector(aSelector));
            return;
        }
        *swizzle = [[ANSSwizzle alloc] initWithBlock:aBlock named:aName forClass:aClass selector:aSelector originalMethod:originalMethod order:order];
    }
}

+ (void)unswizzleSelector:(SEL)aSelector onClass:(Class)aClass named:(NSString *)aName{
    ANSSwizzle * __strong *swizzle = getSwizzleByName(NSStringFromSelector(aSelector));
    if (swizzle && *swizzle) {
        if (aName && [(*swizzle).blocks objectForKey:aName]) {
            [(*swizzle).blocks removeObjectForKey:aName];
        }
    }
}

@end


@implementation ANSSwizzle

- (instancetype)init {
    if ((self = [super init])) {
        self.blocks = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality)
                                            valueOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality)];
    }
    return self;
}

- (instancetype)initWithBlock:(swizzleBlock)aBlock
                        named:(NSString *)aName
                     forClass:(Class)aClass
                     selector:(SEL)aSelector
               originalMethod:(IMP)aMethod
                        order:(AnalysysSwizzleOrder)order {
    if ((self = [self init])) {
        self.class = aClass;
        self.selector = aSelector;
        self.originalMethod = aMethod;
        self.order = order;
        [self.blocks setObject:aBlock forKey:aName];
    }
    return self;
}

- (NSString *)description {
    NSString *descriptors = @"";
    NSString *key;
    NSEnumerator *keys = [self.blocks keyEnumerator];
    while ((key = [keys nextObject])) {
        descriptors = [descriptors stringByAppendingFormat:@"\t%@ : %@\n", key, [self.blocks objectForKey:key]];
    }
    return [NSString stringWithFormat:@"Swizzle on %@::%@ [\n%@]", NSStringFromClass(self.class), NSStringFromSelector(self.selector), descriptors];
}

@end
