//
//  NSThread+ANSHelper.m
//  AnalysysAgent
//
//  Created by SoDo on 2018/7/4.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "NSThread+ANSHelper.h"

@implementation NSThread (ANSHelper)

+ (void)AnsRunOnMainThread:(void (^)(void))block {
    if ([self isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end
