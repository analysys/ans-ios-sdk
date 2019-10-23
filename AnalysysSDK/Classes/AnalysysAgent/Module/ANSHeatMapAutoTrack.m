//
//  ANSHeatMapAutoTrack.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/3/19.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSHeatMapAutoTrack.h"

#import "ANSSwizzler.h"
#import "AnalysysSDK.h"
#import "ANSControllerUtils.h"

#import "ANSConst+private.h"
#import "UIView+ANSAutoTrack.h"
#import "NSThread+ANSHelper.h"


@implementation ANSHeatMapAutoTrack {
    UIView *_touchView; // 记录touchbegan视图，防止end视图为nil
    CGPoint _beginLocation; // 开始点击的位置
    BOOL _isTouchMoved;
    NSString *_appearVC;
}

+ (instancetype)sharedManager {
    static id singleInstance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        if (!singleInstance) {
            singleInstance = [[self alloc] init] ;
        }
    });
    return singleInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [NSThread AnsRunOnMainThread:^{
            void (^viewDidAppearBlock)(id, SEL, id) = ^(UIViewController *obj, SEL sel, NSNumber *num) {
                self->_appearVC = NSStringFromClass(obj.class);
            };
            void (^viewWillDisappearBlock)(id, SEL, id) = ^(UIViewController *obj, SEL sel, NSNumber *num) {
                self->_appearVC = nil;
            };
            
            [ANSSwizzler swizzleSelector:@selector(viewDidAppear:) onClass:[UIViewController class] withBlock:viewDidAppearBlock named:@"ANSHeatmapViewDidAppear"];
            [ANSSwizzler swizzleSelector:@selector(viewWillDisappear:) onClass:[UIViewController class] withBlock:viewWillDisappearBlock named:@"ANSHeatmapViewDidDisappear"];
        }];
    }
    return self;
}

+ (void)heatMapAutoTrack:(BOOL)autoTrack {
    [NSThread AnsRunOnMainThread:^{
        if (autoTrack) {
            [ANSSwizzler swizzleSelector:@selector(sendEvent:) onClass:[UIApplication class] withBlock:^(id view, SEL command, UIEvent *event){
                [[ANSHeatMapAutoTrack sharedManager] ansSentEvent:event];
            } named:@"ANSSendEvent"];
//            [ANSSwizzler swizzleSelector:@selector(sendAction:to:from:forEvent:) onClass:[UIApplication class] withBlock:^(id view,SEL command,SEL action,id to,id from,UIEvent *event){
//                NSLog(@"view:%@", view);
//                NSLog(@"action:%@", NSStringFromSelector(action));
//                NSLog(@"from:%@", from);
//                NSLog(@"to:%@", to);
//                NSLog(@"event:%@", event);
//                NSArray *actions = @[@"ans_preVerify:forEvent:",
//                                     @"ans_execute:forEvent:",
//                                     @"caojiangPreVerify:forEvent:",
//                                     @"caojiangExecute:forEvent:"];
//                if ([actions containsObject:NSStringFromSelector(action)]) {
//                    return ;
//                }
//                if (!event) {
//                    return;
//                }
//                if (event.type == UIEventTypeTouches) {
//                    UITouch *touch = [event.allTouches anyObject];
//                    if (touch.phase == UITouchPhaseEnded) {
//                        NSLog(@"UITouchPhaseEnded");
//                    }
//                }
//
//                [[ANSHeatMapAutoTrack sharedManager] ansSentEvent:event];
//            } named:@"ANSSendAction"];
        } else {
            [ANSSwizzler unswizzleSelector:@selector(sendEvent:) onClass:[UIApplication class] named:@"ANSSendEvent"];
//            [ANSSwizzler unswizzleSelector:@selector(sendAction:to:from:forEvent:) onClass:[UIApplication class] named:@"ANSSendAction"];
        }
    }];
}

/** 触屏事件 */
- (void)ansSentEvent:(UIEvent *)event {
    if (event.type == UIEventTypeTouches) {
        UITouch *touch = [event.allTouches anyObject];
        
        if (touch.phase == UITouchPhaseBegan) {
            if (touch.view == nil) {
                [self trackHeatMap:touch];
            }
            _beginLocation = [touch locationInView:touch.view];
            _touchView = touch.view;
            _isTouchMoved = NO;
        }
        if (touch.phase == UITouchPhaseMoved) {
            CGPoint previousLocation = [touch previousLocationInView:_touchView];
            CGFloat xOffset = fabs(_beginLocation.x - previousLocation.x);
            CGFloat yOffset = fabs(_beginLocation.y - previousLocation.y);
            //NSLog(@"xOffset:%.1f yOffset:%.1f", xOffset, yOffset);
            if (xOffset > 0.1 || yOffset > 0.1) {
                _isTouchMoved = YES;
            }
        }
        if (touch.phase == UITouchPhaseEnded) {
            BOOL isAllowAutoTrack = [_touchView isKindOfClass:[UISlider class]] ? YES : !_isTouchMoved;
            if (isAllowAutoTrack && event.allTouches.count == 1) {
                [self trackHeatMap:touch];
            }
            _isTouchMoved = NO;
            _touchView = nil;
            _beginLocation = CGPointZero;
        }
    }
}

- (void)trackHeatMap:(UITouch *)touch {
//    _touchView = _touchView ?: touch.view;
    if (_touchView == nil) {
        return;
    }
    
    if ([NSStringFromClass(_touchView.class) rangeOfString:@"UIKeyboard"].location != NSNotFound) {
        return;
    }
    
    if ([_touchView.nextResponder.nextResponder isKindOfClass:UISwitch.class]) {
        _touchView = (UISwitch *)_touchView.nextResponder.nextResponder;
    } else if ([_touchView.nextResponder.nextResponder.nextResponder isKindOfClass:UISwitch.class]) {
        _touchView = (UISwitch *)_touchView.nextResponder.nextResponder.nextResponder;
    }
    
    //  兼容iOS 13 presentViewController:页面
    //  且监控textfield控件点击
    if (_appearVC &&
        ![_touchView isKindOfClass:UITextField.class] &&
        ![_touchView isKindOfClass:UITextView.class]) {
        self.viewControllerName = _appearVC;
    } else {
        self.viewControllerName = [_touchView analysysViewControllerName];
    }
    
    if ([[ANSControllerUtils systemBuildInClasses] containsObject:self.viewControllerName]) {
        return;
    }
    
    self.viewToWindowPoint = [touch locationInView:touch.window];
    self.viewToParentPoint = [touch locationInView:_touchView];
    self.elementType = [_touchView analysysElementType];
    self.elementContent = [_touchView analysysElementContent];
    self.elementPath = [_touchView analysysElementPath];
    self.elementClickable = [_touchView analysysElementClickable];
    
    [[AnalysysSDK sharedManager] dispatchOnSerialQueue:^{
        NSDictionary *sdkProperties = [NSDictionary dictionaryWithObjectsAndKeys:self.viewControllerName, ANSPageUrl, nil];
        [[AnalysysSDK sharedManager] trackHeatMapWithSDKProperties:sdkProperties];
    }];
}

@end
