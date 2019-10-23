//
//  ANSObjectSelector.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

/**
 * @class
 * @abstract 埋点控件查找
 *
 * @description 主要处理控件路径匹配
 */

#import <Foundation/Foundation.h>

@interface ANSObjectSelector : NSObject

/** 控件路径 */
@property (nonatomic, strong, readonly) NSString *string;

/** 根据path路径生成selector对象 */
+ (ANSObjectSelector *)objectSelectorWithString:(NSString *)string;
- (instancetype)initWithString:(NSString *)string;

/** 从上往下（父视图->子视图） 查找路径匹配的对象 */
- (NSArray *)selectFromRoot:(id)root;
- (NSArray *)fuzzySelectFromRoot:(id)root;

/** 从下而上（子视图->父视图） 查找当前控件是否与路径匹配 */
- (BOOL)isLeafSelected:(id)leaf fromRoot:(id)root;
- (BOOL)fuzzyIsLeafSelected:(id)leaf fromRoot:(id)root;

- (Class)selectedClass;
- (BOOL)pathContainsObjectOfClass:(Class)klass;
- (NSString *)description;


@end
