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

static ANSSwizzle *UIViewControllerviewWillDisappearSwizzle = nil;
static void ansSwizzledMethodUIViewControllerViewWillDisappear(id self, SEL _cmd, BOOL arg) {
    Class klass = [self class];
    while (klass) {
        if (UIViewControllerviewWillDisappearSwizzle) {
            ((void(*)(id, SEL, BOOL))UIViewControllerviewWillDisappearSwizzle.originalMethod)(self, _cmd, arg);
            
            NSEnumerator *blocks = [UIViewControllerviewWillDisappearSwizzle.blocks objectEnumerator];
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
        ((void(*)(id, SEL, SEL, id, id, id))UIApplicationSendActionToFromForEventSwizzle.originalMethod)(self, _cmd, arg, arg2, arg3, arg4);
        
        NSEnumerator *blocks = [UIApplicationSendActionToFromForEventSwizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2, arg3, arg4);
        }
    }
}

static ANSSwizzle *UIApplicationSendEventSwizzle = nil;
static void ansSwizzledMethodUIApplicationSendEvent(id self, SEL _cmd, id arg) {
    if (UIApplicationSendEventSwizzle) {
        ((void(*)(id, SEL, id))UIApplicationSendEventSwizzle.originalMethod)(self, _cmd, arg);

        NSEnumerator *blocks = [UIApplicationSendEventSwizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg);
        }
    }
}

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

IMP getSwizzleIMPBySELName (NSString * name) {
    if ([name isEqualToString:@"sendEvent:"]) {
        return (IMP)ansSwizzledMethodUIApplicationSendEvent;
    } else if ([name isEqualToString:@"sendAction:to:from:forEvent:"]) {
        return (IMP)ansSwizzledMethodUIApplicationSendActionToFromForEvent;
    } else if ([name isEqualToString:@"application:openURL:options:"]) {
        return (IMP)ansSwizzledMethodUIApplicationOpenURLOptions;
    } else if ([name isEqualToString:@"application:openURL:sourceApplication:annotation:"]) {
        return (IMP)ansSwizzledMethodUIApplicationOpenURLSourceApplicationAnnotation;
    } else if ([name isEqualToString:@"application:handleOpenURL:"]) {
        return (IMP)ansSwizzledMethodUIApplicationHandleOpenURL;
    } else if ([name isEqualToString:@"didMoveToWindow"]) {
        return (IMP)ansSwizzledMethodUIViewDidMoveToWindow;
    } else if ([name isEqualToString:@"didMoveToSuperview"]) {
        return (IMP)ansSwizzledMethodUIViewDidMoveToSuperview;
    } else if ([name isEqualToString:@"tableView:didSelectRowAtIndexPath:"]) {
        return (IMP)ansSwizzledMethodUITableViewDidSelectRowAtIndexPath;
    }  else if ([name isEqualToString:@"trackObject:withEvent:"]) {
        return (IMP)ansSwizzledMethodVisualTrackObjectWithEvent;
    } else if ([name isEqualToString:@"viewWillDisappear:"]) {
        return (IMP)ansSwizzledMethodUIViewControllerViewWillDisappear;
    } else if ([name isEqualToString:@"viewDidAppear:"]) {
        return (IMP)ansSwizzledMethodUIViewControllerViewDidAppear;
    } else if ([name isEqualToString:@"motionBegan:withEvent:"]) {
        return (IMP)ansSwizzledMethodUIApplicationMotionBeganWithEvent;
    } else if ([name isEqualToString:@"application:continueUserActivity:restorationHandler:"]) {
        return (IMP)ansSwizzledMethodUIApplicationContinueUserActivityRestorationHandler;
    }
    return nil;
}

 ANSSwizzle * __strong *getSwizzleByName (NSString * name) {
    if ([name isEqualToString:@"sendEvent:"]) {
        return &UIApplicationSendEventSwizzle;
    } else if ([name isEqualToString:@"sendAction:to:from:forEvent:"]) {
        return &UIApplicationSendActionToFromForEventSwizzle;
    } else if ([name isEqualToString:@"application:openURL:options:"]) {
        return &UIApplicationApplicationOpenURLOptionsSwizzle;
    } else if ([name isEqualToString:@"application:openURL:sourceApplication:annotation:"]) {
        return &UIApplicationApplicationOpenURLSourceApplicationAnnotationSwizzle;
    } else if ([name isEqualToString:@"application:handleOpenURL:"]) {
        return &UIApplicationApplicationHandleOpenURLSwizzle;
    } else if ([name isEqualToString:@"didMoveToWindow"]) {
        return &UIViewDidMoveToWindowSwizzle;
    } else if ([name isEqualToString:@"didMoveToSuperview"]) {
        return &UIViewDidMoveToSuperviewSwizzle;
    } else if ([name isEqualToString:@"tableView:didSelectRowAtIndexPath:"]) {
        return &UITableViewDidSelectRowAtIndexPathSwizzle;
    } else if ([name isEqualToString:@"trackObject:withEvent:"]) {
        return &ANSVisualSDKTrackObjectWithEventSwizzle;
    } else if ([name isEqualToString:@"viewWillDisappear:"]) {
        return &UIViewControllerviewWillDisappearSwizzle;
    } else if ([name isEqualToString:@"viewDidAppear:"]) {
        return &UIViewControllerViewDidAppearSwizzle;
    } else if ([name isEqualToString:@"motionBegan:withEvent:"]) {
        return &UIApplicationMotionBeganWithEventSwizzle;
    } else if ([name isEqualToString:@"application:continueUserActivity:restorationHandler:"]) {
        return &UIApplicationContinueUserActivitySwizzle;
    }
    return nil;
}
