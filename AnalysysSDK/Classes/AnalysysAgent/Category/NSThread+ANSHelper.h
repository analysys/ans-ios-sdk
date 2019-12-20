//
//  NSThread+ANSHelper.h
//  AnalysysAgent
//
//  Created by SoDo on 2018/7/4.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSThread (ANSHelper)

/// 主线程执行
/// @param block 回调
+ (void)ansRunOnMainThread:(void (^)(void))block;

@end
