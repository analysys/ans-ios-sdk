//
//  UIColor+Transform.h
//  EGAnalyticsDemo
//
//  Created by analysys on 2018/4/24.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Transform)

// 颜色转换：iOS中（以#开头）十六进制的颜色转换为UIColor(RGB)
+ (UIColor *)colorWithHexString:(NSString *)color;

@end
