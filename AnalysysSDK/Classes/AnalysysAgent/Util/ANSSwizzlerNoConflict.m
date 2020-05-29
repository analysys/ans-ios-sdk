//
//  ANSSwizzlerNoConflict.m
//  AnalysysAgent
//
//  Created by jesse on 2019/8/13.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANSSwizzler.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

/*++++++++++++++++++++++++  no conflict methord start  ++++++++++++++++++++++++*/


static ANSSwizzle *UIApplicationMotionBeganWithEventSwizzle = nil;
static void ansSwizzledMethodUIApplicationMotionBeganWithEvent(id self, SEL _cmd, UIEventSubtype motion, UIEvent *event) {
    Class klass = [self class];
    while (klass) {
        if (UIApplicationMotionBeganWithEventSwizzle) {
            ((void(*)(id, SEL, UIEventSubtype, UIEvent*))UIApplicationMotionBeganWithEventSwizzle.originalMethod)(self, _cmd, motion, event);
            
            NSEnumerator *blocks = [UIApplicationMotionBeganWithEventSwizzle.blocks objectEnumerator];
            swizzleBlock block;
            while((block = [blocks nextObject])) {
                block(self, _cmd, [NSNumber numberWithBool:motion], event);
            }
            break;
        }
        klass = class_getSuperclass(klass);
    }
}

static ANSSwizzle *UIViewControllerViewDidAppearSwizzle = nil;
static void ansSwizzledMethodUIViewControllerViewDidAppear(id self, SEL _cmd, BOOL arg) {
    Class klass = [self class];
    while (klass) {
        if (UIViewControllerViewDidAppearSwizzle) {
            ((void(*)(id, SEL, BOOL))UIViewControllerViewDidAppearSwizzle.originalMethod)(self, _cmd, arg);
            
            NSEnumerator *blocks = [UIViewControllerViewDidAppearSwizzle.blocks objectEnumerator];
            swizzleBlock block;
            while((block = [blocks nextObject])) {
                block(self, _cmd, [NSNumber numberWithBool:arg]);
            }
            break;
        }
        klass = class_getSuperclass(klass);
    }
}

static ANSSwizzle *UIViewControllerviewDidDisappearSwizzle = nil;
static void ansSwizzledMethodUIViewControllerViewDidDisappear(id self, SEL _cmd, BOOL arg) {
    Class klass = [self class];
    while (klass) {
        if (UIViewControllerviewDidDisappearSwizzle) {
            ((void(*)(id, SEL, BOOL))UIViewControllerviewDidDisappearSwizzle.originalMethod)(self, _cmd, arg);
            
            NSEnumerator *blocks = [UIViewControllerviewDidDisappearSwizzle.blocks objectEnumerator];
            swizzleBlock block;
            while((block = [blocks nextObject])) {
                block(self, _cmd, [NSNumber numberWithBool:arg]);
            }
            break;
        }
        klass = class_getSuperclass(klass);
    }
}

static ANSSwizzle *UITableViewDidSelectRowAtIndexPathSwizzle = nil;
static void ansSwizzledMethodUITableViewDidSelectRowAtIndexPath(id self, SEL _cmd, id arg, id arg2) {
    if (UITableViewDidSelectRowAtIndexPathSwizzle) {
        ((void(*)(id, SEL, id, id))UITableViewDidSelectRowAtIndexPathSwizzle.originalMethod)(self, _cmd, arg, arg2);
        
        NSEnumerator *blocks = [UITableViewDidSelectRowAtIndexPathSwizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2);
        }
    }
}

static ANSSwizzle *UICollectionViewDidSelectItemAtIndexPathSwizzle = nil;
static void ansSwizzledMethodUICollectionViewDidSelectItemAtIndexPath(id self, SEL _cmd, id arg, id arg2) {
    if (UICollectionViewDidSelectItemAtIndexPathSwizzle) {
        ((void(*)(id, SEL, id, id))UICollectionViewDidSelectItemAtIndexPathSwizzle.originalMethod)(self, _cmd, arg, arg2);
        
        NSEnumerator *blocks = [UICollectionViewDidSelectItemAtIndexPathSwizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2);
        }
    }
}


static ANSSwizzle *ANSVisualSDKTrackObjectWithEventSwizzle = nil;
static void ansSwizzledMethodVisualTrackObjectWithEvent(id self, SEL _cmd, id arg, id arg2) {
    if (ANSVisualSDKTrackObjectWithEventSwizzle) {
        ((void(*)(id, SEL, id, id))ANSVisualSDKTrackObjectWithEventSwizzle.originalMethod)(self, _cmd, arg, arg2);
        
        NSEnumerator *blocks = [ANSVisualSDKTrackObjectWithEventSwizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2);
        }
    }
}

static ANSSwizzle *UIViewDidMoveToSuperviewSwizzle = nil;
static void ansSwizzledMethodUIViewDidMoveToSuperview(id self, SEL _cmd) {
    if (UIViewDidMoveToSuperviewSwizzle) {
        ((void(*)(id, SEL))UIViewDidMoveToSuperviewSwizzle.originalMethod)(self, _cmd);
        
        NSEnumerator *blocks = [UIViewDidMoveToSuperviewSwizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd);
        }
    }
}

static ANSSwizzle *UIViewDidMoveToWindowSwizzle = nil;
static void ansSwizzledMethodUIViewDidMoveToWindow(id self, SEL _cmd) {
    if (UIViewDidMoveToWindowSwizzle) {
        ((void(*)(id, SEL))UIViewDidMoveToWindowSwizzle.originalMethod)(self, _cmd);
        
        NSEnumerator *blocks = [UIViewDidMoveToWindowSwizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd);
        }
    }
}

//  app调起
static ANSSwizzle *UIApplicationApplicationHandleOpenURLSwizzle = nil;
static void ansSwizzledMethodUIApplicationHandleOpenURL(id self, SEL _cmd, id arg, id arg2) {
    if (UIApplicationApplicationHandleOpenURLSwizzle) {
        ((void(*)(id, SEL, id, id))UIApplicationApplicationHandleOpenURLSwizzle.originalMethod)(self, _cmd, arg, arg2);
        
        NSEnumerator *blocks = [UIApplicationApplicationHandleOpenURLSwizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2);
        }
    }
}

// App调起
static ANSSwizzle *UIApplicationApplicationOpenURLSourceApplicationAnnotationSwizzle = nil;
static void ansSwizzledMethodUIApplicationOpenURLSourceApplicationAnnotation(id self, SEL _cmd, id arg, id arg2, id arg3, id arg4) {
    if (UIApplicationApplicationOpenURLSourceApplicationAnnotationSwizzle) {
        ((void(*)(id, SEL, id, id, id, id))UIApplicationApplicationOpenURLSourceApplicationAnnotationSwizzle.originalMethod)(self, _cmd, arg, arg2, arg3, arg4);
        
        NSEnumerator *blocks = [UIApplicationApplicationOpenURLSourceApplicationAnnotationSwizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2, arg3, arg4);
        }
    }
}

//  App调起
static ANSSwizzle *UIApplicationApplicationOpenURLOptionsSwizzle = nil;
static void ansSwizzledMethodUIApplicationOpenURLOptions(id self, SEL _cmd, id arg, id arg2, id arg3) {
    if (UIApplicationApplicationOpenURLOptionsSwizzle) {
        ((void(*)(id, SEL, id, id, id))UIApplicationApplicationOpenURLOptionsSwizzle.originalMethod)(self, _cmd, arg, arg2, arg3);
        
        NSEnumerator *blocks = [UIApplicationApplicationOpenURLOptionsSwizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2, arg3);
        }
    }
}

static ANSSwizzle *UIApplicationSendActionToFromForEventSwizzle = nil;
static void ansSwizzledMethodUIApplicationSendActionToFromForEvent(id self, SEL _cmd, SEL arg, id arg2, id arg3, id arg4) {
    if (UIApplicationSendActionToFromForEventSwizzle) {
        NSEnumerator *blocks = [UIApplicationSendActionToFromForEventSwizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2, arg3, arg4);
        }
        ((void(*)(id, SEL, SEL, id, id, id))UIApplicationSendActionToFromForEventSwizzle.originalMethod)(self, _cmd, arg, arg2, arg3, arg4);
    }
}

static ANSSwizzle *ANSSendEventSwizzle = nil;
static void ansSwizzledSendEvent(id self, SEL _cmd, id arg) {
    if (ANSSendEventSwizzle) {
        if (ANSSendEventSwizzle.order == AnalysysSwizzleOrderBefore) {
            NSEnumerator *blocks = [ANSSendEventSwizzle.blocks objectEnumerator];
            swizzleBlock block;
            while((block = [blocks nextObject])) {
                block(self, _cmd, arg);
            }
            ((void(*)(id, SEL, id))ANSSendEventSwizzle.originalMethod)(self, _cmd, arg);
        } else {
            ((void(*)(id, SEL, id))ANSSendEventSwizzle.originalMethod)(self, _cmd, arg);
            NSEnumerator *blocks = [ANSSendEventSwizzle.blocks objectEnumerator];
            swizzleBlock block;
            while((block = [blocks nextObject])) {
                block(self, _cmd, arg);
            }
        }
    }
}

//static ANSSwizzle *UIApplicationSendEventSwizzle = nil;
//static void ansSwizzledMethodUIApplicationSendEvent(id self, SEL _cmd, id arg) {
//    if (UIApplicationSendEventSwizzle) {
//        NSEnumerator<NSString *> *keys = [UIApplicationSendEventSwizzle.blocks keyEnumerator];
//        NSArray<NSString *> *keysArray = keys.allObjects;
//        if (keysArray != nil && keysArray.count >0) {
//            for (int i=0; i<keysArray.count; i++) {
//                NSString *key = keysArray[i];
//                if ([key isKindOfClass:[NSString class]] && key.length >0 && [key hasPrefix:@"pre_excute_"]) {
//                    swizzleBlock block = [UIApplicationSendEventSwizzle.blocks objectForKey:key];
//                    if (block) {
//                        block(self, _cmd, arg);
//                    }
//                }
//            }
//        }
//        ((void(*)(id, SEL, id))UIApplicationSendEventSwizzle.originalMethod)(self, _cmd, arg);
//        if (keysArray != nil && keysArray.count >0) {
//            for (int i=0; i<keysArray.count; i++) {
//                NSString *key = keysArray[i];
//                if ([key isKindOfClass:[NSString class]] && key.length >0 && ![key hasPrefix:@"pre_excute_"]) {
//                    swizzleBlock block = [UIApplicationSendEventSwizzle.blocks objectForKey:key];
//                    if (block) {
//                        block(self, _cmd, arg);
//                    }
//                }
//            }
//        }
//    }
//}

static ANSSwizzle *UIApplicationContinueUserActivitySwizzle = nil;
static void ansSwizzledMethodUIApplicationContinueUserActivityRestorationHandler(id self, SEL _cmd, id arg, id arg2, id arg3) {
    if (UIApplicationContinueUserActivitySwizzle) {
        ((void(*)(id, SEL, id, id, id))UIApplicationContinueUserActivitySwizzle.originalMethod)(self, _cmd, arg, arg2, arg3);
        
        NSEnumerator *blocks = [UIApplicationContinueUserActivitySwizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2, arg3);
        }
    }
}

// 3DTouch
static ANSSwizzle *UIApplicationPerformActionForShortcutItemSwizzle = nil;
static void ansSwizzledMethodUIApplicationPerformActionForShortcutItemHandler(id self, SEL _cmd, id arg, id arg2, id arg3) {
    if (UIApplicationPerformActionForShortcutItemSwizzle) {
        ((void(*)(id, SEL, id, id, id))UIApplicationPerformActionForShortcutItemSwizzle.originalMethod)(self, _cmd, arg, arg2, arg3);
        
        NSEnumerator *blocks = [UIApplicationPerformActionForShortcutItemSwizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2, arg3);
        }
    }
}

//  10.0推送
static ANSSwizzle *UIApplicationDidReceiveNotificationResponseSwizzle = nil;
static void ansSwizzledMethodUIApplicationDidReceiveNotificationResponseHandler(id self, SEL _cmd, id arg, id arg2, id arg3) {
    if (UIApplicationDidReceiveNotificationResponseSwizzle) {
        ((void(*)(id, SEL, id, id, id))UIApplicationDidReceiveNotificationResponseSwizzle.originalMethod)(self, _cmd, arg, arg2, arg3);
        
        NSEnumerator *blocks = [UIApplicationDidReceiveNotificationResponseSwizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2, arg3);
        }
    }
}

// < iOS7.0 推送
static ANSSwizzle *UIApplicationDidReceiveRemoteNotificationSwizzle = nil;
static void ansSwizzledMethodUIApplicationDidReceiveRemoteNotification(id self, SEL _cmd, id arg, id arg2) {
    if (UIApplicationDidReceiveRemoteNotificationSwizzle) {
        ((void(*)(id, SEL, id, id))UIApplicationDidReceiveRemoteNotificationSwizzle.originalMethod)(self, _cmd, arg, arg2);
        
        NSEnumerator *blocks = [UIApplicationDidReceiveRemoteNotificationSwizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2);
        }
    }
}

//  iOS 7.0 ~ iOS 9.0 推送
static ANSSwizzle *UIApplicationDidReceiveRemoteNotificationHandlerSwizzle = nil;
static void ansSwizzledMethodUIApplicationDidReceiveRemoteNotificationHandler(id self, SEL _cmd, id arg, id arg2, id arg3) {
    if (UIApplicationDidReceiveRemoteNotificationHandlerSwizzle) {
        ((void(*)(id, SEL, id, id, id))UIApplicationDidReceiveRemoteNotificationHandlerSwizzle.originalMethod)(self, _cmd, arg, arg2, arg3);
        
        NSEnumerator *blocks = [UIApplicationDidReceiveRemoteNotificationHandlerSwizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2, arg3);
        }
    }
}

static NSString *const ANSSendEvent = @"sendEvent:";
static NSString *const ANSSendActionToFromForEvent = @"sendAction:to:from:forEvent:";
static NSString *const ANSOpenURLOptions = @"application:openURL:options:";
static NSString *const ANSOpenURLSourceApplicationAnnotation = @"application:openURL:sourceApplication:annotation:";
static NSString *const ANSHandleOpenURL = @"application:handleOpenURL:";
static NSString *const ANSDidMoveToWindow = @"didMoveToWindow";
static NSString *const ANSDidMoveToSuperview = @"didMoveToSuperview";
static NSString *const ANSTableViewSelect = @"tableView:didSelectRowAtIndexPath:";
static NSString *const ANSCollectionViewSelect = @"collectionView:didSelectItemAtIndexPath:";
static NSString *const ANSVisualTrack = @"trackObject:withEvent:";
static NSString *const ANSViewDidDisappear = @"viewDidDisappear:";
static NSString *const ANSViewDidAppear = @"viewDidAppear:";
static NSString *const ANSMontion = @"motionBegan:withEvent:";
static NSString *const ANSUserActivity = @"application:continueUserActivity:restorationHandler:";
static NSString *const ANSShortcutItem = @"application:performActionForShortcutItem:completionHandler:";
static NSString *const ANSReceiveNotificationResponse = @"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:";
static NSString *const ANSReceiveNotification = @"application:didReceiveRemoteNotification:";
static NSString *const ANSReceiveNotificationHandler = @"application:didReceiveRemoteNotification:fetchCompletionHandler:";

IMP getSwizzleIMPBySELName (NSString * name) {
    if ([name isEqualToString:ANSSendEvent]) {
        return (IMP)ansSwizzledSendEvent;
    } else if ([name isEqualToString:ANSSendActionToFromForEvent]) {
        return (IMP)ansSwizzledMethodUIApplicationSendActionToFromForEvent;
    } else if ([name isEqualToString:ANSOpenURLOptions]) {
        return (IMP)ansSwizzledMethodUIApplicationOpenURLOptions;
    } else if ([name isEqualToString:ANSOpenURLSourceApplicationAnnotation]) {
        return (IMP)ansSwizzledMethodUIApplicationOpenURLSourceApplicationAnnotation;
    } else if ([name isEqualToString:ANSHandleOpenURL]) {
        return (IMP)ansSwizzledMethodUIApplicationHandleOpenURL;
    } else if ([name isEqualToString:ANSDidMoveToWindow]) {
        return (IMP)ansSwizzledMethodUIViewDidMoveToWindow;
    } else if ([name isEqualToString:ANSDidMoveToSuperview]) {
        return (IMP)ansSwizzledMethodUIViewDidMoveToSuperview;
    } else if ([name isEqualToString:ANSTableViewSelect]) {
        return (IMP)ansSwizzledMethodUITableViewDidSelectRowAtIndexPath;
    } else if ([name isEqualToString:ANSCollectionViewSelect]) {
        return (IMP)ansSwizzledMethodUICollectionViewDidSelectItemAtIndexPath;
    } else if ([name isEqualToString:ANSVisualTrack]) {
        return (IMP)ansSwizzledMethodVisualTrackObjectWithEvent;
    } else if ([name isEqualToString:ANSViewDidDisappear]) {
        return (IMP)ansSwizzledMethodUIViewControllerViewDidDisappear;
    } else if ([name isEqualToString:ANSViewDidAppear]) {
        return (IMP)ansSwizzledMethodUIViewControllerViewDidAppear;
    } else if ([name isEqualToString:ANSMontion]) {
        return (IMP)ansSwizzledMethodUIApplicationMotionBeganWithEvent;
    } else if ([name isEqualToString:ANSUserActivity]) {
        return (IMP)ansSwizzledMethodUIApplicationContinueUserActivityRestorationHandler;
    } else if ([name isEqualToString:ANSShortcutItem]) {
        return (IMP)ansSwizzledMethodUIApplicationPerformActionForShortcutItemHandler;
    } else if([name isEqualToString:ANSReceiveNotificationResponse]) {
        return (IMP)ansSwizzledMethodUIApplicationDidReceiveNotificationResponseHandler;
    } else if ([name isEqualToString:ANSReceiveNotification]) {
        return (IMP)ansSwizzledMethodUIApplicationDidReceiveRemoteNotification;
    } else if ([name isEqualToString:ANSReceiveNotificationHandler]) {
        return (IMP)ansSwizzledMethodUIApplicationDidReceiveRemoteNotificationHandler;
    }
    return nil;
}

ANSSwizzle * __strong *getSwizzleByName (NSString * name) {
    if ([name isEqualToString:ANSSendEvent]) {
        return &ANSSendEventSwizzle;
    } else if ([name isEqualToString:ANSSendActionToFromForEvent]) {
        return &UIApplicationSendActionToFromForEventSwizzle;
    } else if ([name isEqualToString:ANSOpenURLOptions]) {
        return &UIApplicationApplicationOpenURLOptionsSwizzle;
    } else if ([name isEqualToString:ANSOpenURLSourceApplicationAnnotation]) {
        return &UIApplicationApplicationOpenURLSourceApplicationAnnotationSwizzle;
    } else if ([name isEqualToString:ANSHandleOpenURL]) {
        return &UIApplicationApplicationHandleOpenURLSwizzle;
    } else if ([name isEqualToString:ANSDidMoveToWindow]) {
        return &UIViewDidMoveToWindowSwizzle;
    } else if ([name isEqualToString:ANSDidMoveToSuperview]) {
        return &UIViewDidMoveToSuperviewSwizzle;
    } else if ([name isEqualToString:ANSTableViewSelect]) {
        return &UITableViewDidSelectRowAtIndexPathSwizzle;
    } else if ([name isEqualToString:ANSCollectionViewSelect]) {
        return &UICollectionViewDidSelectItemAtIndexPathSwizzle;
    } else if ([name isEqualToString:ANSVisualTrack]) {
        return &ANSVisualSDKTrackObjectWithEventSwizzle;
    } else if ([name isEqualToString:ANSViewDidDisappear]) {
        return &UIViewControllerviewDidDisappearSwizzle;
    } else if ([name isEqualToString:ANSViewDidAppear]) {
        return &UIViewControllerViewDidAppearSwizzle;
    } else if ([name isEqualToString:ANSMontion]) {
        return &UIApplicationMotionBeganWithEventSwizzle;
    } else if ([name isEqualToString:ANSUserActivity]) {
        return &UIApplicationContinueUserActivitySwizzle;
    } else if ([name isEqualToString:ANSShortcutItem]) {
        return &UIApplicationPerformActionForShortcutItemSwizzle;
    } else if([name isEqualToString:ANSReceiveNotificationResponse]) {
        return &UIApplicationDidReceiveNotificationResponseSwizzle;
    } else if ([name isEqualToString:ANSReceiveNotification]) {
        return &UIApplicationDidReceiveRemoteNotificationSwizzle;
    } else if ([name isEqualToString:ANSReceiveNotificationHandler]) {
        return &UIApplicationDidReceiveRemoteNotificationHandlerSwizzle;
    }
    return nil;
}
