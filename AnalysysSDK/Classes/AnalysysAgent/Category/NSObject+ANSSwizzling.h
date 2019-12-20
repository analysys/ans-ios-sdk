//
//  NSObject+ANSSwizzling.h
//  AnalysysAgent
//
//  Created by analysys on 2017/2/22.
//  Copyright © 2017年 Analysys. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (ANSSwizzling)

/// 方法交换
/// @param originalSel 原方法
/// @param replacedSel 替换后方法
+ (void)ansExchangeOriginalSel:(SEL)originalSel replacedSel:(SEL)replacedSel;

@end
