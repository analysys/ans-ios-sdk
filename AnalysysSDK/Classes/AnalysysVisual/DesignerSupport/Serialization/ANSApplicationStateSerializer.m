//
//  ANSApplicationStateSerializer.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSApplicationStateSerializer.h"

#import <QuartzCore/QuartzCore.h>
#import "ANSClassDescription.h"
#import "ANSObjectIdentityProvider.h"
#import "ANSObjectSerializer.h"
#import "ANSObjectSerializerConfig.h"

#import "ANSConsoleLog.h"

@implementation ANSApplicationStateSerializer {
    ANSObjectSerializer *_serializer;
    UIApplication *_application;
}


- (instancetype)initWithApplication:(UIApplication *)application configuration:(ANSObjectSerializerConfig *)configuration objectIdentityProvider:(ANSObjectIdentityProvider *)objectIdentityProvider {
    NSParameterAssert(application != nil);
    NSParameterAssert(configuration != nil);
    
    self = [super init];
    if (self) {
        _application = application;
        _serializer = [[ANSObjectSerializer alloc] initWithConfiguration:configuration objectIdentityProvider:objectIdentityProvider];
    }
    
    return self;
}

/** 当前截屏 */
- (UIImage *)screenshotImageForWindowAtIndex:(NSUInteger)index {
    UIImage *image = nil;
    
    UIWindow *window = [self windowAtIndex:index];
    if (window && !CGRectEqualToRect(window.frame, CGRectZero)) {
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, YES, window.screen.scale);
        if ([window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO] == NO) {
            AnsDebug(@"Unable to get complete screenshot for window at index: %d.", (int)index);
        }
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

- (UIWindow *)windowAtIndex:(NSUInteger)index {
    NSParameterAssert(index < _application.windows.count);
    UIWindow *currentWindow = _application.windows[index];
    if (!currentWindow.hidden) {
        return currentWindow;
    }
    for (UIWindow *window in _application.windows) {
        if (!window.hidden) {
            currentWindow = window;
            break;
        }
    }
    return currentWindow;
}

/** 图层结构列表 */
- (NSDictionary *)objectHierarchyForWindowAtIndex:(NSUInteger)index {
    UIWindow *window = [self windowAtIndex:index];
    if (window) {
        return [_serializer serializedObjectsWithRootObject:window];
    }
    
    return @{};
}


@end
