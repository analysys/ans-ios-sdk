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
#import "ANSConsoleLog.h"
#import "NSThread+AnsHelper.h"
#import "UIView+ANSHelper.h"

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
        AnsDebug(@"must supply a view path to bind by");
        return nil;
    }
    
    NSString *eventName = object[@"event_id"];
    if (![eventName isKindOfClass:[NSString class]] || eventName.length < 1 ) {
        AnsDebug(@"binding requires an event name");
        return nil;
    }
    
    if (!([object[@"control_event"] unsignedIntegerValue] & UIControlEventAllEvents)) {
        AnsDebug(@"must supply a valid UIControlEvents value for control_event");
        return nil;
    }
    
    UIControlEvents verifyEvent = [object[@"verify_event"] unsignedIntegerValue];
    return [[ANSUIControlBinding alloc] initWithEventName:eventName
                                                  onPath:path
                                        withControlEvent:[object[@"control_event"] unsignedIntegerValue]
                                          andVerifyEvent:verifyEvent
                                               matchText:object[@"match_text"]
                                             bindingInfo:object];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
+ (ANSEventBinding *)bindngWithJSONObject:(NSDictionary *)object {
    return [self bindingWithJSONObject:object];
}
#pragma clang diagnostic pop

- (instancetype)initWithEventName:(NSString *)eventName
                           onPath:(NSString *)path
                 withControlEvent:(UIControlEvents)controlEvent
                   andVerifyEvent:(UIControlEvents)verifyEvent
                        matchText:(NSString *)matchText
                      bindingInfo:(NSDictionary *)bindingInfo {
    if (self = [super initWithEventName:eventName onPath:path matchText:matchText bindingInfo:bindingInfo]) {
        // iOS 12: UITextField now implements -didMoveToWindow, without calling the parent implementation. so Swizzle UIControl won't work
        if ([UIDevice currentDevice].systemVersion.floatValue >= 12.0) {
            [self setSwizzleClass:[path containsString:@"UITextField"] ? [UITextField class] : [UIControl class]];
        } else {
            [self setSwizzleClass:[UIControl class]];
        }
        _controlEvent = controlEvent;
        if (verifyEvent == 0) {
            if (controlEvent & UIControlEventAllTouchEvents) {
                verifyEvent = UIControlEventTouchDown;
            } else if (controlEvent & UIControlEventAllEditingEvents) {
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
        void (^executeBlock)(id, SEL) = ^(id view, SEL command) {
            [NSThread AnsRunOnMainThread:^{
                NSArray *objects;
                NSObject *root = [self getRootObject];
                if (view && [self.appliedTo containsObject:view]) {
                    //  离开页面 移除绑定
                    if (![self.path fuzzyIsLeafSelected:view fromRoot:root]) {
                        [self stopOnView:view];
                        [self.appliedTo removeObject:view];
                    }
                } else {
                    // select targets based off path
                    if (view) {
                        //  进入页面
                        if ([self.path fuzzyIsLeafSelected:view fromRoot:root]) {
                            objects = @[view];
                        } else {
                            objects = @[];
                        }
                    } else {
                        //  新增埋点
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
    [NSThread AnsRunOnMainThread:^{
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
    NSObject *root = [self getRootObject];
    return [self.path isLeafSelected:control fromRoot:root];
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
        //  文本匹配
        if (!self.matchText ||
            (self.matchText && [self.matchText isEqualToString:[sender AnsElementText]]) ) {
            [[self class] trackObject:sender withEventBinding:self];
        }
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
- (NSObject *)getRootObject {
    NSObject *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (!root) {
        root = [UIApplication sharedApplication].delegate.window.rootViewController;
    }
    return root;
}

#pragma mark - 对象比较

/** 重写对象比较方法 */
- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![other isKindOfClass:[ANSUIControlBinding class]]) {
        return NO;
    } else {
        return [super isEqual:other] &&
        self.controlEvent == ((ANSUIControlBinding *)other).controlEvent &&
        self.verifyEvent == ((ANSUIControlBinding *)other).verifyEvent;
    }
}

/** 重写hash方法 */
- (NSUInteger)hash {
    return [super hash] ^ self.controlEvent ^ self.verifyEvent;
}


@end
