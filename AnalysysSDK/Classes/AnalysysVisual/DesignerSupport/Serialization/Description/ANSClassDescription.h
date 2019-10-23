//
//  ANSClassDescription.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

/**
 *  服务器下发配置信息中类的描述信息
 *  包括类之间的继承关系和代理关系等
 *  下发配置中 父类信息一定在前 子类在后
 */

#import "ANSTypeDescription.h"

@interface ANSClassDescription : ANSTypeDescription

/** 父类描述信息 */
@property (nonatomic, readonly) ANSClassDescription *superclassDescription;
/** 当前类属性信息 */
@property (nonatomic, readonly) NSArray *propertyDescriptions;
/** 当前类代理信息 */
@property (nonatomic, readonly) NSArray *delegateInfos;

/** 初始化解析方法 */
- (instancetype)initWithSuperclassDescription:(ANSClassDescription *)superclassDescription dictionary:(NSDictionary *)dictionary;

- (BOOL)isDescriptionForKindOfClass:(Class)aClass;


@end




/**
 * 服务器下发配置信息中的代理信息
 */
@interface ANSDelegateInfo : NSObject

@property (nonatomic, readonly) NSString *selectorName;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end



