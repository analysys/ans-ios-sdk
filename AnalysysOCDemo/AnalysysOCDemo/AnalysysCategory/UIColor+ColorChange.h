//
//  UIColor+ColorChange.h
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/8/6.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (ColorChange)

// 颜色转换：iOS中（以#开头）十六进制的颜色转换为UIColor(RGB)
+ (UIColor *) colorWithHexString: (NSString *)color;

@end

NS_ASSUME_NONNULL_END
