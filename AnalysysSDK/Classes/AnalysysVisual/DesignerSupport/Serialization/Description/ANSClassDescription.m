//
//  ANSClassDescription.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSClassDescription.h"

#import "ANSPropertyDescription.h"

@implementation ANSDelegateInfo

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _selectorName = dictionary[@"selector"];
    }
    return self;
}

@end

@implementation ANSClassDescription {
    NSArray *_propertyDescriptions;
    NSArray *_delegateInfos;
}

/** 解析配置信息 */
- (instancetype)initWithSuperclassDescription:(ANSClassDescription *)superclassDescription dictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        _superclassDescription = superclassDescription;
        
        NSMutableArray *propertyDescriptions = [NSMutableArray array];
        for (NSDictionary *propertyDictionary in dictionary[@"properties"]) {
            [propertyDescriptions addObject:[[ANSPropertyDescription alloc] initWithDictionary:propertyDictionary]];
        }
        
        _propertyDescriptions = [propertyDescriptions copy];
        
        NSMutableArray *delegateInfos = [NSMutableArray array];
        for (NSDictionary *delegateInfoDictionary in dictionary[@"delegateImplements"]) {
            [delegateInfos addObject:[[ANSDelegateInfo alloc] initWithDictionary:delegateInfoDictionary]];
        }
        _delegateInfos = [delegateInfos copy];
    }
    
    return self;
}

/** 获取当前类所有属性信息（包含其父类属性） */
- (NSArray *)propertyDescriptions {
    NSMutableDictionary *allPropertyDescriptions = [NSMutableDictionary dictionary];
    
    ANSClassDescription *description = self;
    while (description) {
        for (ANSPropertyDescription *propertyDescription in description->_propertyDescriptions) {
            if (!allPropertyDescriptions[propertyDescription.name]) {
                allPropertyDescriptions[propertyDescription.name] = propertyDescription;
            }
        }
        description = description.superclassDescription;
    }
    
    return allPropertyDescriptions.allValues;
}

- (BOOL)isDescriptionForKindOfClass:(Class)aClass {
    return [self.name isEqualToString:NSStringFromClass(aClass)] && [self.superclassDescription isDescriptionForKindOfClass:[aClass superclass]];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p name='%@' superclass='%@'>", NSStringFromClass([self class]), (__bridge void *)self, self.name, self.superclassDescription ? self.superclassDescription.name : @""];
}

@end
