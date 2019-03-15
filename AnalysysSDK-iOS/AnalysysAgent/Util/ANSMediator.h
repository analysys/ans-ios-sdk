//
//  ANSMediator.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/21.
//  Copyright © 2019 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * @class
 * ANSMediator
 *
 * @abstract
 * 反射调用
 *
 * @discussion
 * 通过反射方式调用相应方法
 */


@interface ANSMediator : NSObject

/**
 使用invocation反射调用

 @param target 对象
 @param actionName 方法字符串
 @return 返回值
 */
+ (id)performTarget:(id)target action:(NSString *)actionName;

/**
 携带参数反射调用

 @param target 对象
 @param actionName 方法字符串
 @param parameters 参数列表
 @return 返回值
 */
+ (id)performTarget:(id)target action:(NSString *)actionName params:(NSArray *)parameters;

@end


