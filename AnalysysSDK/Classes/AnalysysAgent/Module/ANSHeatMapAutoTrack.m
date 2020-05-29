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

@interface ANSHeatMapAutoTrack()

@property (nonatomic, assign) BOOL autoTrack;
@property (nonatomic, weak) UIViewController *currentViewController;
@property (nonatomic, weak) UIView *touchView; // 记录touchbegan视图，防止end视图为nil

@end

@implementation ANSHeatMapAutoTrack {
    CGPoint _beginLocation; // 开始点击的位置
    BOOL _isTouchMoved;
}

+ (instancetype)sharedManager {
    static id singleHeatMapInstance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        if (!singleHeatMapInstance) {
            singleHeatMapInstance = [[self alloc] init];
        }
    });
    return singleHeatMapInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.ignoreAutoClickPage = [NSMutableSet set];
        self.autoClickPage = [NSMutableSet set];
    }
    return self;
}

+ (void)heatMapAutoTrack:(BOOL)autoTrack {
    [ANSHeatMapAutoTrack sharedManager].autoTrack = autoTrack;
    [NSThread ansRunOnMainThread:^{
        if (autoTrack) {
            [ANSSwizzler swizzleSelector:@selector(sendEvent:) onClass:[UIApplication class] withBlock:^(id view, SEL command, UIEvent *event){
                [[ANSHeatMapAutoTrack sharedManager] ansSentEvent:event];
            } named:@"ANSSendEvent" order:AnalysysSwizzleOrderBefore];
        } else {
            [ANSSwizzler unswizzleSelector:@selector(sendEvent:) onClass:[UIApplication class] named:@"ANSSendEvent"];
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
    
    self.currentViewController = [ANSControllerUtils currentViewController];
    if (!self.currentViewController || [[ANSControllerUtils systemBuildInClasses] containsObject:NSStringFromClass(self.currentViewController.class)]) {
        return;
    }
    
    self.viewToWindowPoint = [touch locationInView:touch.window];
    self.viewToParentPoint = [touch locationInView:_touchView];
    self.elementType = [_touchView analysysElementType];
    self.elementContent = [_touchView analysysElementContent];
    self.elementPath = [_touchView analysysElementPath];
    self.elementClickable = [_touchView analysysElementClickable];
    
    //获取当前响应事件的控制器
    if ([self checkIsReport:_touchView withTargat:self.currentViewController]) {
        NSDictionary *sdkProperties = [NSDictionary dictionaryWithObjectsAndKeys:self.viewControllerName, ANSPageUrl, nil];
        [[AnalysysSDK sharedManager] trackHeatMapWithSDKProperties:sdkProperties];
    } else {
        
    }
}

//检查黑白名单，看是否上报
- (BOOL)checkIsReport:(UIView *)view withTargat:(UIViewController *)target {
    if (self.autoTrack) {
        if ([self.ignoreAutoClickPage containsObject:NSStringFromClass([target class])]) {
            return NO;
        } else if (self.autoClickPage.count > 0) {
            if ([self.autoClickPage containsObject:NSStringFromClass([target class])]) {
                return YES;
            } else {
                return NO;
            }
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

- (NSString *)viewControllerName {
    NSString *vc = NSStringFromClass(self.currentViewController.class);
    return vc ?: @"";
}

@end
