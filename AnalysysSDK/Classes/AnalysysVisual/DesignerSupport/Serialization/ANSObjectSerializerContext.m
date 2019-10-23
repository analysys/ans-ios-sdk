//
//  ANSObjectSerializerContext.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSObjectSerializerContext.h"

@implementation ANSObjectSerializerContext {
    NSMutableSet *_visitedObjects;
    NSMutableSet *_unvisitedObjects;
    NSMutableDictionary *_serializedObjects;
}

- (instancetype)initWithRootObject:(id)object {
    self = [super init];
    if (self) {
        _visitedObjects = [NSMutableSet set];
        _unvisitedObjects = [NSMutableSet setWithObject:object];
        _serializedObjects = [NSMutableDictionary dictionary];
    }
    
    return self;
}

//   是否有未遍历的对象
- (BOOL)hasUnvisitedObjects {
    return _unvisitedObjects.count > 0;
}

- (void)enqueueUnvisitedObject:(NSObject *)object {
    NSParameterAssert(object != nil);
    
    [_unvisitedObjects addObject:object];
}

//  随机获取一个未遍历对应，并将其移除
- (NSObject *)dequeueUnvisitedObject {
    NSObject *object = [_unvisitedObjects anyObject];
    [_unvisitedObjects removeObject:object];
    
    return object;
}

/** 添加已访问对象数组 */
- (void)addVisitedObject:(NSObject *)object {
    NSParameterAssert(object != nil);
    
    [_visitedObjects addObject:object];
}

- (BOOL)isVisitedObject:(NSObject *)object {
    return object && [_visitedObjects containsObject:object];
}

- (void)addSerializedObject:(NSDictionary *)serializedObject {
    NSParameterAssert(serializedObject[@"id"] != nil);
    _serializedObjects[serializedObject[@"id"]] = serializedObject;
}

- (NSArray *)allSerializedObjects {
    return _serializedObjects.allValues;
}

@end
