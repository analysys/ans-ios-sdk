//
//  ANSProtocolSwizzler.h
//
//  Created by Analysys on 2019/11/27.
//  Copyright (c) 2019 Analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

// Cast to turn things that are not ids into NSMapTable keys
#define ANS_MAPTABLE_ID(x) (__bridge id)((void *)x)

// Ignore the warning cause we need the paramters to be dynamic and it's only being used internally
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
typedef void (^swizzleBlock)();
#pragma clang diagnostic pop

@interface ANSProtocolSwizzler : NSObject

+ (void)swizzleSelector:(SEL)aSelector onClass:(Class)aClass withBlock:(swizzleBlock)block named:(NSString *)aName;
+ (void)unswizzleSelector:(SEL)aSelector onClass:(Class)aClass named:(NSString *)aName;

@end
