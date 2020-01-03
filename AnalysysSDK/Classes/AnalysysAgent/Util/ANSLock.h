//
//  ANSLock.h
//  AnalysysAgent
//
//  Created by xiao xu on 2019/10/11.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define AgentLock() dispatch_semaphore_wait([ANSLock ans_semaphore_lock], DISPATCH_TIME_FOREVER);
#define AgentUnlock() dispatch_semaphore_signal([ANSLock ans_semaphore_lock]);

#define ANSPropertyLock() [[ANSLock ans_property_lock] lock];
#define ANSPropertyUnlock() [[ANSLock ans_property_lock] unlock];

#define ANSUserDefaultsLock() [[ANSLock ans_userDefaults_lock] lock];
#define ANSUserDefaultsUnlock() [[ANSLock ans_userDefaults_lock] unlock];

@interface ANSLock : NSObject

+ (dispatch_semaphore_t)ans_semaphore_lock;
+ (NSLock *)ans_property_lock;
+ (NSLock *)ans_userDefaults_lock;

@end

NS_ASSUME_NONNULL_END
