//
//  ANSProtocolSwizzler.m
//
//  Created by Analysys on 2019/11/27.
//  Copyright (c) 2019 Analysys. All rights reserved.
//

#import <objc/runtime.h>
#import "AnalysysLogger.h"
#import "ANSProtocolSwizzler.h"

#define ANS_MIN_ARGS 2
#define ANS_MAX_ARGS 5

@interface ANSProtocolSwizzle : NSObject

@property (nonatomic, assign) Class class;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) IMP originalMethod;
@property (nonatomic, assign) uint numArgs;
@property (nonatomic, copy) NSMapTable *blocks;

- (instancetype)initWithBlock:(swizzleBlock)aBlock
              named:(NSString *)aName
           forClass:(Class)aClass
           selector:(SEL)aSelector
     originalMethod:(IMP)aMethod
        withNumArgs:(uint)numArgs;

@end

static NSMapTable *ans_swizzles;

static void ans_swizzledMethod_2(id self, SEL _cmd)
{
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    ANSProtocolSwizzle *swizzle = (ANSProtocolSwizzle *)[ans_swizzles objectForKey:ANS_MAPTABLE_ID(aMethod)];
    if (swizzle) {
        ((void(*)(id, SEL))swizzle.originalMethod)(self, _cmd);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while ((block = [blocks nextObject])) {
            block(self, _cmd);
        }
    }
}

static void ans_swizzledMethod_3(id self, SEL _cmd, id arg)
{
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    ANSProtocolSwizzle *swizzle = (ANSProtocolSwizzle *)[ans_swizzles objectForKey:ANS_MAPTABLE_ID(aMethod)];
    if (swizzle) {
        ((void(*)(id, SEL, id))swizzle.originalMethod)(self, _cmd, arg);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while ((block = [blocks nextObject])) {
            block(self, _cmd, arg);
        }
    }
}

static void ans_swizzledMethod_4(id self, SEL _cmd, id arg, id arg2)
{
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    ANSProtocolSwizzle *swizzle = (ANSProtocolSwizzle *)[ans_swizzles objectForKey:(__bridge id)((void *)aMethod)];
    if (swizzle) {
        ((void(*)(id, SEL, id, id))swizzle.originalMethod)(self, _cmd, arg, arg2);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while ((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2);
        }
    }
}

static void ans_swizzledMethod_5(id self, SEL _cmd, id arg, id arg2, id arg3)
{
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    ANSProtocolSwizzle *swizzle = (ANSProtocolSwizzle *)[ans_swizzles objectForKey:(__bridge id)((void *)aMethod)];
    if (swizzle) {
        ((void(*)(id, SEL, id, id, id))swizzle.originalMethod)(self, _cmd, arg, arg2, arg3);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while ((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2, arg3);
        }
    }
}

// Ignore the warning cause we need the paramters to be dynamic and it's only being used internally
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
static void (*mp_swizzledMethods[ANS_MAX_ARGS - ANS_MIN_ARGS + 1])() = {ans_swizzledMethod_2, ans_swizzledMethod_3, ans_swizzledMethod_4, ans_swizzledMethod_5};
#pragma clang diagnostic pop

@implementation ANSProtocolSwizzler

+ (void)load
{
    ans_swizzles = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality)
                                     valueOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality)];
}

+ (ANSProtocolSwizzle *)swizzleForMethod:(Method)aMethod
{
    return (ANSProtocolSwizzle *)[ans_swizzles objectForKey:ANS_MAPTABLE_ID(aMethod)];
}

+ (void)removeSwizzleForMethod:(Method)aMethod
{
    [ans_swizzles removeObjectForKey:ANS_MAPTABLE_ID(aMethod)];
}

+ (void)setSwizzle:(ANSProtocolSwizzle *)swizzle forMethod:(Method)aMethod
{
    [ans_swizzles setObject:swizzle forKey:ANS_MAPTABLE_ID(aMethod)];
}

+ (BOOL)isLocallyDefinedMethod:(Method)aMethod onClass:(Class)aClass
{
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

+ (void)swizzleSelector:(SEL)aSelector onClass:(Class)aClass withBlock:(swizzleBlock)aBlock named:(NSString *)aName
{
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    if (aMethod) {
        uint numArgs = method_getNumberOfArguments(aMethod);
        if (numArgs >= ANS_MIN_ARGS && numArgs <= ANS_MAX_ARGS) {
                
            BOOL isLocal = [self isLocallyDefinedMethod:aMethod onClass:aClass];
            IMP swizzledMethod = (IMP)mp_swizzledMethods[numArgs - 2];
            ANSProtocolSwizzle *swizzle = [self swizzleForMethod:aMethod];
                
            if (isLocal) {
                if (!swizzle) {
                    IMP originalMethod = method_getImplementation(aMethod);
                        
                    // Replace the local implementation of this method with the swizzled one
                    method_setImplementation(aMethod,swizzledMethod);
                        
                    // Create and add the swizzle
                    swizzle = [[ANSProtocolSwizzle alloc] initWithBlock:aBlock named:aName forClass:aClass selector:aSelector originalMethod:originalMethod withNumArgs:numArgs];
                    [self setSwizzle:swizzle forMethod:aMethod];
                        
                } else {
                    [swizzle.blocks setObject:aBlock forKey:aName];
                }
            } else {
                IMP originalMethod = swizzle ? swizzle.originalMethod : method_getImplementation(aMethod);
                    
                // Add the swizzle as a new local method on the class.
                if (!class_addMethod(aClass, aSelector, swizzledMethod, method_getTypeEncoding(aMethod))) {
                    ANSDebug(@"SwizzlerAssert: Could not add swizzled for %@::%@, even though it didn't already exist locally", NSStringFromClass(aClass), NSStringFromSelector(aSelector));
                    return;
                }
                // Now re-get the Method, it should be the one we just added.
                Method newMethod = class_getInstanceMethod(aClass, aSelector);
                if (aMethod == newMethod) {
                    ANSDebug(@"SwizzlerAssert: Newly added method for %@::%@ was the same as the old method", NSStringFromClass(aClass), NSStringFromSelector(aSelector));
                    return;
                }
                    
                ANSProtocolSwizzle *newSwizzle = [[ANSProtocolSwizzle alloc] initWithBlock:aBlock named:aName forClass:aClass selector:aSelector originalMethod:originalMethod withNumArgs:numArgs];
                [self setSwizzle:newSwizzle forMethod:newMethod];
            }
        } else {
            ANSDebug(@"SwizzlerAssert: Cannot swizzle method with %d args", numArgs);
        }
    } else {
        ANSDebug(@"SwizzlerAssert: Cannot find method for %@ on %@", NSStringFromSelector(aSelector), NSStringFromClass(aClass));
    }
}

+ (void)unswizzleSelector:(SEL)aSelector onClass:(Class)aClass
{
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    ANSProtocolSwizzle *swizzle = [self swizzleForMethod:aMethod];
    if (swizzle) {
        method_setImplementation(aMethod, swizzle.originalMethod);
        [self removeSwizzleForMethod:aMethod];
    }
}

/*
 Remove the named swizzle from the given class/selector. If aName is nil, remove all
 swizzles for this class/selector
*/
+ (void)unswizzleSelector:(SEL)aSelector onClass:(Class)aClass named:(NSString *)aName
{
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    ANSProtocolSwizzle *swizzle = [self swizzleForMethod:aMethod];
    if (swizzle) {
        if (aName) {
            [swizzle.blocks removeObjectForKey:aName];
        }
        if (!aName || swizzle.blocks.count == 0) {
            method_setImplementation(aMethod, swizzle.originalMethod);
            [self removeSwizzleForMethod:aMethod];
        }
    }
}

@end


@implementation ANSProtocolSwizzle

- (instancetype)init
{
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
        withNumArgs:(uint)numArgs
{
    if ((self = [self init])) {
        self.class = aClass;
        self.selector = aSelector;
        self.numArgs = numArgs;
        self.originalMethod = aMethod;
        [self.blocks setObject:aBlock forKey:aName];
    }
    return self;
}

- (NSString *)description
{
    NSString *descriptors = @"";
    NSString *key;
    NSEnumerator *keys = [self.blocks keyEnumerator];
    while ((key = [keys nextObject])) {
        descriptors = [descriptors stringByAppendingFormat:@"\t%@ : %@\n", key, [self.blocks objectForKey:key]];
    }
    return [NSString stringWithFormat:@"Swizzle on %@::%@ [\n%@]", NSStringFromClass(self.class), NSStringFromSelector(self.selector), descriptors];
}

@end
