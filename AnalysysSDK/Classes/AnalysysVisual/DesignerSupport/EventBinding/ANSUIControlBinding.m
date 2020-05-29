//
//  ANSUIControlBinding.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSUIControlBinding.h"
#import "ANSSwizzler.h"
#import "AnalysysLogger.h"
#import "NSThread+AnsHelper.h"
#import "ANSVisualSDK.h"
#import "ANSUtil.h"

@interface ANSUIControlBinding()

/*
 This table contains all the UIControls we are currently bound to
 */
@property (nonatomic, copy) NSHashTable *appliedTo;
/*
 A table of all objects that matched the full path including
 predicates the last time they dispatched a UIControlEventTouchDown
 */
@property (nonatomic, copy) NSHashTable *verified;

- (void)stopOnView:(UIView *)view;

@end

#pragma mark - ANSUIControlBinding


@implementation ANSUIControlBinding

+ (NSString *)typeName {
    return @"ui_control";
}

+ (ANSEventBinding *)bindingWithJSONObject:(NSDictionary *)object {
    NSString *path = object[@"path"];
    if (![path isKindOfClass:[NSString class]] || path.length < 1) {
        ANSDebug(@"must supply a view path to bind by");
        return nil;
    }
    
    NSString *eventName = object[@"event_id"];
    if (![eventName isKindOfClass:[NSString class]] || eventName.length < 1 ) {
        ANSDebug(@"binding requires an event name");
        return nil;
    }
    
    if (!([object[@"control_event"] unsignedIntegerValue] & UIControlEventAllEvents)) {
        ANSDebug(@"must supply a valid UIControlEvents value for control_event");
        return nil;
    }
    
    return [[ANSUIControlBinding alloc] initWithBindingInfo:object];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
+ (ANSEventBinding *)bindngWithJSONObject:(NSDictionary *)object {
    return [self bindingWithJSONObject:object];
}
#pragma clang diagnostic pop

- (instancetype)initWithBindingInfo:(NSDictionary *)bindingInfo {
    if (self = [super initWithEventBindingInfo:bindingInfo]) {
        // iOS 12: UITextField now implements -didMoveToWindow, without calling the parent implementation. so Swizzle UIControl won't work
        NSString *path = bindingInfo[@"path"];
        if (@available(iOS 12.0, *)) {
            [self setSwizzleClass:[path containsString:@"UITextField"] ? [UITextField class] : [UIControl class]];
        } else {
            [self setSwizzleClass:[UIControl class]];
        }
        _controlEvent = [bindingInfo[@"control_event"] unsignedIntegerValue];
        UIControlEvents verifyEvent = [bindingInfo[@"verify_event"] unsignedIntegerValue];
        if (verifyEvent == 0) {
            if (_controlEvent & UIControlEventAllTouchEvents) {
                verifyEvent = UIControlEventTouchDown;
            } else if (_controlEvent & UIControlEventAllEditingEvents) {
                verifyEvent = UIControlEventEditingDidBegin;
            }
        }
        _verifyEvent = verifyEvent;
        
        [self resetAppliedTo];
        
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Event Binding: '%@' for '%@'", [self eventName], [self path]];
}

- (void)resetAppliedTo {
    self.verified = [NSHashTable hashTableWithOptions:(NSHashTableWeakMemory|NSHashTableObjectPointerPersonality)];
    self.appliedTo = [NSHashTable hashTableWithOptions:(NSHashTableWeakMemory|NSHashTableObjectPointerPersonality)];
}

#pragma mark -- Executing Actions

/**
 执行可视化事件绑定操作
 */
- (void)executeVisualEventBinding {
    if (!self.appliedTo) {
        [self resetAppliedTo];
    }
    
    if (!self.running) {
        //  是否当次循环
        static BOOL isInLoop = YES;
        void (^executeBlock)(id, SEL) = ^(id view, SEL command) {
            [NSThread ansRunOnMainThread:^{
                NSArray *objects;
                NSSet *rootObjects = [self getRootObject];
                if (rootObjects.count == 0) {
                    return;
                }
                isInLoop = YES;
                for (NSObject *root in rootObjects) {
                    if (view && [self.appliedTo containsObject:view]) {
                        if (isInLoop) {
                            //  当次遍历不进行绑定移除操作
                            return;
                        }
                        if (![self.path fuzzyIsLeafSelected:view fromRoot:root]) {
                            [self stopOnView:view];
                            [self.appliedTo removeObject:view];
                        }
                    } else {
                        // select targets based off path
                        if (view) {
                            if ([self.path fuzzyIsLeafSelected:view fromRoot:root]) {
                                objects = @[view];
                            } else {
                                objects = @[];
                            }
                        } else {
                            //  首次请求数据立即埋点绑定
                            objects = [self.path fuzzySelectFromRoot:root];
                        }
                        
                        //  绑定事件
                        for (UIControl *control in objects) {
                            if ([control isKindOfClass:[UIControl class]]) {
                                if (self.verifyEvent != 0 && self.verifyEvent != self.controlEvent) {
                                    [control addTarget:self
                                                action:@selector(ans_preVerify:forEvent:)
                                      forControlEvents:self.verifyEvent];
                                }
                                
                                [control addTarget:self
                                            action:@selector(ans_execute:forEvent:)
                                  forControlEvents:self.controlEvent];
                                [self.appliedTo addObject:control];
                            }
                        }
                    }
                }
                isInLoop = NO;
            }];
        };
        
        executeBlock(nil, _cmd);
        
        [ANSSwizzler swizzleSelector:NSSelectorFromString(@"didMoveToWindow")
                             onClass:self.swizzleClass
                           withBlock:executeBlock
                               named:self.name];
        [ANSSwizzler swizzleSelector:NSSelectorFromString(@"didMoveToSuperview")
                             onClass:self.swizzleClass
                           withBlock:executeBlock
                               named:self.name];
        self.running = true;
    }
}

- (void)stop {
    if (self.running) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        // remove what has been swizzled
        [ANSSwizzler unswizzleSelector:NSSelectorFromString(@"didMoveToWindow")
                               onClass:self.swizzleClass
                                 named:self.name];
        [ANSSwizzler unswizzleSelector:NSSelectorFromString(@"didMoveToSuperview")
                               onClass:self.swizzleClass
                                 named:self.name];
        
        // remove target-action pairs
        for (UIControl *control in self.appliedTo.allObjects) {
            if (control && [control isKindOfClass:[UIControl class]]) {
                [self stopOnView:control];
            }
        }
        [self resetAppliedTo];
        self.running = false;
    }
}

- (void)stopOnView:(UIControl *)view {
    [NSThread ansRunOnMainThread:^{
        if (self.verifyEvent != 0 && self.verifyEvent != self.controlEvent) {
            [view removeTarget:self
                        action:@selector(ans_preVerify:forEvent:)
              forControlEvents:self.verifyEvent];
        }
        
        [view removeTarget:self
                    action:@selector(ans_execute:forEvent:)
          forControlEvents:self.controlEvent];
    }];
}

#pragma mark -- To execute for Target-Action event firing

- (BOOL)verifyControlMatchesPath:(id)control {
    NSSet *rootObjects = [self getRootObject];
    for (NSObject *root in rootObjects) {
        if ([self.path isLeafSelected:control fromRoot:root]) {
            return YES;
        }
    }
    return NO;
}

- (void)ans_preVerify:(id)sender forEvent:(UIEvent *)event {
    if ([self verifyControlMatchesPath:sender]) {
        [self.verified addObject:sender];
    } else {
        [self.verified removeObject:sender];
    }
}

- (void)ans_execute:(UIControl *)sender forEvent:(UIEvent *)event {
    BOOL shouldTrack;
    if (self.verifyEvent != 0 && self.verifyEvent != self.controlEvent) {
        shouldTrack = [self.verified containsObject:sender];
    } else {
        shouldTrack = [self verifyControlMatchesPath:sender];
    }
    if (shouldTrack) {
        // 页面匹配
        if (self.targetPage && ![self.targetPage isEqualToString:[ANSVisualSDK sharedManager].currentPage]) {
            return;
        }
        //  文本匹配
        if (self.matchText && ![self.matchText isEqualToString:[ANSVisualSDK sharedManager].controlText]) {
            return;
        }
        [[self class] trackObject:sender withEventBinding:self];
    }
}

#pragma mark -- NSCoder

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:@(_controlEvent) forKey:@"controlEvent"];
    [aCoder encodeObject:@(_verifyEvent) forKey:@"verifyEvent"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _controlEvent = [[aDecoder decodeObjectForKey:@"controlEvent"] unsignedIntegerValue];
        _verifyEvent = [[aDecoder decodeObjectForKey:@"verifyEvent"] unsignedIntegerValue];
    }
    return self;
}

/** 获取根视图 */
- (NSSet *)getRootObject {
    UIWindow *window = [ANSUtil currentKeyWindow];
    NSObject *rootVC = window.rootViewController;
    return [NSSet setWithObjects:rootVC, window, nil];
}

#pragma mark - 对象比较

/** 重写对象比较方法 */
- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (![other isKindOfClass:[ANSUIControlBinding class]]) {
        return NO;
    }
    return [super isEqual:other] &&
    self.controlEvent == ((ANSUIControlBinding *)other).controlEvent &&
    self.verifyEvent == ((ANSUIControlBinding *)other).verifyEvent;
}

/** 重写hash方法 */
- (NSUInteger)hash {
    return [super hash] ^ self.controlEvent ^ self.verifyEvent;
}


@end
