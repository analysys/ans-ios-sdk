//
//  ANSTypeDescription.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSTypeDescription.h"

@implementation ANSTypeDescription


- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _name = [dictionary[@"name"] copy];
    }
    
    return self;
}


@end
