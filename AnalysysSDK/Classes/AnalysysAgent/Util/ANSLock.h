//
//  ANSLock.h
//  AnalysysAgent
//
//  Created by xiao xu on 2019/10/11.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define AgentLock() dispatch_semaphore_wait(ans_semaphore_lock(), DISPATCH_TIME_FOREVER);
#define AgentUnlock() dispatch_semaphore_signal(ans_semaphore_lock());

#define ANSPropertyLock() [ans_property_lock() lock];
#define ANSPropertyUnlock() [ans_property_lock() unlock];

#define ANSUserDefaultsLock() [ans_userDefaults_lock() lock];
#define ANSUserDefaultsUnlock() [ans_userDefaults_lock() unlock];

static dispatch_semaphore_t ans_semaphore_lock() {
    static dispatch_semaphore_t _ans_semaphore_lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ans_semaphore_lock = dispatch_semaphore_create(0);
    });
    return _ans_semaphore_lock;
}

static NSLock *ans_property_lock() {
    static NSLock *_ans_property_lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ans_property_lock = [[NSLock alloc] init];
    });
    return _ans_property_lock;
}

static NSLock *ans_userDefaults_lock() {
    static NSLock *_ans_userDefaults_lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ans_userDefaults_lock = [[NSLock alloc] init];
    });
    return _ans_userDefaults_lock;
}

@interface ANSLock : NSObject

@end

NS_ASSUME_NONNULL_END
