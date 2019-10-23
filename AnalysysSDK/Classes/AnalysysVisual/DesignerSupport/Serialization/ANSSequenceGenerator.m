//
//  ANSSequenceGenerator.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSSequenceGenerator.h"

#import <libkern/OSAtomic.h>

@implementation ANSSequenceGenerator {
    int32_t _value;
}

- (instancetype)init {
    return [self initWithInitialValue:0];
}

- (instancetype)initWithInitialValue:(int32_t)initialValue {
    self = [super init];
    if (self) {
        _value = initialValue;
    }
    
    return self;
}

- (int32_t)nextValue {
    return OSAtomicAdd32(1, &_value);
}

@end
