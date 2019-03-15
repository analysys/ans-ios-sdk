//
//  ANSSwizzler.h
//  AnalysysAgent
//
//  Created by analysys on 2018/2/6.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

// Cast to turn things that are not ids into NSMapTable keys
#define MAPTABLE_ID(x) (__bridge id)((void *)x)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
typedef void (^swizzleBlock)();
#pragma clang diagnostic pop

@interface ANSSwizzler : NSObject

/** hook 参数为对象类型的方法 */
+ (void)swizzleSelector:(SEL)aSelector onClass:(Class)aClass withBlock:(swizzleBlock)block named:(NSString *)aName;

/** hook 页面监测 */
+ (void)swizzleBoolSelector:(SEL)aSelector onClass:(Class)aClass withBlock:(swizzleBlock)aBlock named:(NSString *)aName;

+ (void)unswizzleSelector:(SEL)aSelector onClass:(Class)aClass named:(NSString *)aName;

+ (void)printSwizzles;

@end
