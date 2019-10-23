//
//  ANSObjectIdentityProvider.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSObjectIdentityProvider.h"

#import "ANSSequenceGenerator.h"

@implementation ANSObjectIdentityProvider {
    NSMapTable *_objectToIdentifierMap;
    ANSSequenceGenerator *_sequenceGenerator;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _objectToIdentifierMap = [NSMapTable weakToStrongObjectsMapTable];
        _sequenceGenerator = [[ANSSequenceGenerator alloc] init];
    }
    
    return self;
}

/** 获取当前对象标识并保存，若没有则生成 */
- (NSString *)identifierForObject:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    }
    NSString *identifier = [_objectToIdentifierMap objectForKey:object];
    if (identifier == nil) {
        identifier = [NSString stringWithFormat:@"$%" PRIi32, [_sequenceGenerator nextValue]];
        [_objectToIdentifierMap setObject:identifier forKey:object];
    }
    
    return identifier;
}

@end
