//
//  ANSPropertyDescription.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import <Foundation/Foundation.h>

@class ANSObjectSerializerContext;

////**************************** 属性selector参数 ****************************////

/**
 * 配置信息 - 类描述 - 属性描述 - set/get - selector - 参数描述
 */
@interface ANSPropertySelectorParameterDescription : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
/** 参数名称 */
@property (nonatomic, readonly) NSString *name;
/** 参数类型 */
@property (nonatomic, readonly) NSString *type;

@end

////**************************** 属性selector ****************************////

/**
 * 配置信息 - 类描述 - 属性描述 - set/get - selector
 */
@interface ANSPropertySelectorDescription : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
/** selector */
@property (nonatomic, readonly) NSString *selectorName;
/** 值类型 */
@property (nonatomic, readonly) NSString *returnType;
/** 参数描述 数组 */
@property (nonatomic, readonly) NSArray *parameters;

@end


////**************************** 属性信息 ****************************////

/**
 * 服务器下发的config中classes对应的properties(属性)描述信息
 * 如：属性名称、类型、读写性、是否允许跟踪、是否支持kvc模式等
 */

@interface ANSPropertyDescription : NSObject


- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/** 属性名 */
@property (nonatomic, readonly) NSString *name;
/** 属性类型 */
@property (nonatomic, readonly) NSString *type;
/** 是否只读 */
@property (nonatomic, readonly) BOOL readonly;
@property (nonatomic, readonly) BOOL nofollow;
/** 是否可使用kvc模式获取属性 */
@property (nonatomic, readonly) BOOL useKeyValueCoding;
/** 是否可以使用运行时变量 */
@property (nonatomic, readonly) BOOL useInstanceVariableAccess;
/** get 属性信息 */
@property (nonatomic, readonly) ANSPropertySelectorDescription *getSelectorDescription;
/** set 属性信息 */
@property (nonatomic, readonly) ANSPropertySelectorDescription *setSelectorDescription;

- (BOOL)shouldReadPropertyValueForObject:(NSObject *)object;

- (NSValueTransformer *)valueTransformer;


@end






