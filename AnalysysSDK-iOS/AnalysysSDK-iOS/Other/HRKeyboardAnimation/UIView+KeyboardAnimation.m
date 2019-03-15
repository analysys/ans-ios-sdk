//
//  UIView+KeyboardAnimation.m
//  FHSupportOldAge
//
//  Created by 许昊然 on 16/7/19.
//  Copyright © 2016年 许昊然. All rights reserved.
//

#import "UIView+KeyboardAnimation.h"
#import <objc/runtime.h>
#import "UIView+CustomLayout.h"

#define VIEWINTERVAL 30 //  键盘距离当前编辑控件的间隔


@implementation UIView (KeyboardAnimation)

static char kEditingTextKey;

- (UITextField *)editingText {
    return objc_getAssociatedObject(self, &kEditingTextKey);
}

- (void)setEditingText:(UITextField *)editingText {
    objc_setAssociatedObject(self, &kEditingTextKey, editingText, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)addKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (UITextField *)getIsEditingText {
    [self getIsEditingView:self];
    return self.editingText;
}

- (void)keyboardWillShow:(NSNotification *)noti {
    [self getIsEditingView:self];
    CGFloat viewY = self.editingText.screenViewYValue;
    NSDictionary *userInfo = [noti userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyboardEndY = value.CGRectValue.origin.y;
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:duration.doubleValue animations:^{
        if (viewY+self.editingText.heightValue+VIEWINTERVAL > keyboardEndY) {
            self.topValue += keyboardEndY - (viewY+self.editingText.heightValue+VIEWINTERVAL);
        }
    }];
}

- (void)keyboardWillHide:(NSNotification *)noti {
    self.topValue = 0;
}

- (void)getIsEditingView:(UIView *)rootView {
    for (UIView *subView in rootView.subviews) {
        if ([subView isKindOfClass:[UITextField class]] || [subView isKindOfClass:[UITextView class]]) {
            if (((UITextField *)subView).isEditing) {
                self.editingText = (UITextField *)subView;
                return;
            }
        }
        [self getIsEditingView:subView];
    }
}

@end
