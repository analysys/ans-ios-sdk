//
//  ANSSequenceGenerator.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

/**
 * @class
 * @abstract 对象标识序列生成类
 */

#import <Foundation/Foundation.h>

@interface ANSSequenceGenerator : NSObject

- (int32_t)nextValue;

@end
