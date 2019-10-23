//
//  NSThread+ANSHelper.h
//  AnalysysAgent
//
//  Created by SoDo on 2018/7/4.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSThread (ANSHelper)

+ (void)AnsRunOnMainThread:(void (^)(void))block;

@end
