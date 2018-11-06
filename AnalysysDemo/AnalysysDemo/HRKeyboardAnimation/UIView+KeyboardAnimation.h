//
//  UIView+KeyboardAnimation.h
//  FHSupportOldAge
//
//  Created by 许昊然 on 16/7/19.
//  Copyright © 2016年 许昊然. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (KeyboardAnimation)
/**
 *  托管键盘弹出通知
 */
- (void)addKeyboardNotification;
/**
 *  移除托管通知
 */
- (void)removeKeyboardNotification;
/**
 *  获得编辑的textfield
 *
 *  @return textfield
 */
- (UITextField *)getIsEditingText;
@end
