//
//  ANSLock.m
//  AnalysysAgent
//
//  Created by xiao xu on 2019/10/11.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSLock.h"

@implementation ANSLock

+ (dispatch_semaphore_t)ans_semaphore_lock {
    static dispatch_semaphore_t _ans_semaphore_lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ans_semaphore_lock = dispatch_semaphore_create(0);
    });
    return _ans_semaphore_lock;
}

+ (NSLock *)ans_property_lock {
    static NSLock *_ans_property_lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ans_property_lock = [[NSLock alloc] init];
    });
    return _ans_property_lock;
}

+ (NSLock *)ans_userDefaults_lock {
    static NSLock *_ans_userDefaults_lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ans_userDefaults_lock = [[NSLock alloc] init];
    });
    return _ans_userDefaults_lock;
}

@end
