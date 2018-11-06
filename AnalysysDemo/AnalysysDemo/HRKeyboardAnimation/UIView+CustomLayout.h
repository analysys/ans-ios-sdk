//
//  UIView+CustomLayout.h
//  FHSupportOldAge
//
//  Created by 许昊然 on 16/7/11.
//  Copyright © 2016年 许昊然. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CustomLayout)

/**
 *  上下左右宽高中心
 */
@property(nonatomic) CGFloat leftValue;
@property(nonatomic) CGFloat topValue;
@property(nonatomic) CGFloat rightValue;
@property(nonatomic) CGFloat bottomValue;
@property(nonatomic) CGFloat widthValue;
@property(nonatomic) CGFloat heightValue;
@property(nonatomic) CGFloat centerXValue;
@property(nonatomic) CGFloat centerYValue;

/**
 *  距离屏幕的绝对距离
 */
@property(nonatomic,readonly) CGFloat screenXValue;
@property(nonatomic,readonly) CGFloat screenYValue;
/**
 *  距离屏幕的相对距离
 */
@property(nonatomic,readonly) CGFloat screenViewXValue;
@property(nonatomic,readonly) CGFloat screenViewYValue;
@property(nonatomic,readonly) CGRect screenFrameValue;

@property(nonatomic) CGPoint originValue;
@property(nonatomic) CGSize sizeValue;

@end
