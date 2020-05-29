//
//  ANSSwizzler.h
//  AnalysysAgent
//
//  Created by analysys on 2018/2/6.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
typedef void (^swizzleBlock)();
#pragma clang diagnostic pop

//  交换方法时，SDK方法与系统方法的先后执行顺序
typedef NS_ENUM(NSInteger, AnalysysSwizzleOrder) {
    AnalysysSwizzleOrderBefore,  // SDK在前，系统在后
    AnalysysSwizzleOrderAfter  // 系统在前，SDK在后
};

@interface ANSSwizzler : NSObject


/**
 hook方法

 @param aSelector sel
 @param aClass class
 @param aBlock 回调函数
 @param aName hook标识
 */
+ (void)swizzleSelector:(SEL)aSelector onClass:(Class)aClass withBlock:(swizzleBlock)aBlock named:(NSString *)aName;

+ (void)swizzleSelector:(SEL)aSelector
                onClass:(Class)aClass
              withBlock:(swizzleBlock)aBlock
                  named:(NSString *)aName
                  order:(AnalysysSwizzleOrder)order;

/**
 取消hook

 @param aSelector sel
 @param aClass class
 @param aName hook标识
 */
+ (void)unswizzleSelector:(SEL)aSelector onClass:(Class)aClass named:(NSString *)aName;

@end

@interface ANSSwizzle : NSObject
@property (nonatomic, assign) Class class;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) IMP originalMethod;
@property (nonatomic, assign) uint numArgs;
@property (nonatomic, copy) NSMapTable *blocks;
@property (nonatomic, assign) AnalysysSwizzleOrder order;

- (instancetype)initWithBlock:(swizzleBlock)aBlock
                        named:(NSString *)aName
                     forClass:(Class)aClass
                     selector:(SEL)aSelector
               originalMethod:(IMP)aMethod
                        order:(AnalysysSwizzleOrder)order;
@end
