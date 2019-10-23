//
//  ANSObjectSerializerContext.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

/** 管理图层中对象的访问情况 */

#import <Foundation/Foundation.h>

@interface ANSObjectSerializerContext : NSObject

/** 初始化对象 */
- (instancetype)initWithRootObject:(id)object;

/** 是否有未遍历的对象 */
- (BOOL)hasUnvisitedObjects;

/** 添加未访问对象 */
- (void)enqueueUnvisitedObject:(NSObject *)object;
/** 随机获取未访问对象 */
- (NSObject *)dequeueUnvisitedObject;

/** 添加已访问对象数组 */
- (void)addVisitedObject:(NSObject *)object;
/** object 是否已访问过 */
- (BOOL)isVisitedObject:(NSObject *)object;

/** 添加已序列化对象 */
- (void)addSerializedObject:(NSDictionary *)serializedObject;
/** 获取所有序列化数据 */
- (NSArray *)allSerializedObjects;


@end
