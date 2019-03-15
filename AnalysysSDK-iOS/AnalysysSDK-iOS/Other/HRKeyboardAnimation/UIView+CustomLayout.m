//
//  UIView+CustomLayout.m
//  FHSupportOldAge
//
//  Created by 许昊然 on 16/7/11.
//  Copyright © 2016年 许昊然. All rights reserved.
//

#import "UIView+CustomLayout.h"

@implementation UIView (CustomLayout)

- (CGFloat)leftValue {
    return self.frame.origin.x;
}

- (void)setLeftValue:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)topValue {
    return self.frame.origin.y;
}

- (void)setTopValue:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)rightValue {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRightValue:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottomValue {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottomValue:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)centerXValue {
    return self.center.x;
}

- (void)setCenterXValue:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerYValue {
    return self.center.y;
}

- (void)setCenterYValue:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)widthValue {
    return self.frame.size.width;
}

- (void)setWidthValue:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)heightValue {
    return self.frame.size.height;
}

- (void)setHeightValue:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)screenXValue {
    CGFloat x = 0;
    for (UIView *view = self; view; view = view.superview) {
        x += view.leftValue;
    }
    return x;
}

- (CGFloat)screenYValue {
    CGFloat y = 0;
    for (UIView *view = self; view; view = view.superview) {
        y += view.topValue;
    }
    return y;
}

- (CGFloat)screenViewXValue {
    CGFloat x = 0;
    for (UIView *view = self; view; view = view.superview) {
        x += view.leftValue;
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            x -= scrollView.contentOffset.x;
        }
    }
    
    return x;
}

- (CGFloat)screenViewYValue {
    CGFloat y = 0;
    for (UIView *view = self; view; view = view.superview) {
        y += view.topValue;
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            y -= scrollView.contentOffset.y;
        }
    }
    return y;
}

- (CGRect)screenFrameValue {
    return CGRectMake(self.screenViewXValue, self.screenViewYValue, self.widthValue, self.heightValue);
}

- (CGPoint)originValue {
    return self.frame.origin;
}

- (void)setOriginValue:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)sizeValue {
    return self.frame.size;
}

- (void)setSizeValue:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

@end
