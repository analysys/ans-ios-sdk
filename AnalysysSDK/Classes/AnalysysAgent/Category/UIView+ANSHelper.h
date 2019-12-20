//
//  UIView+ANSHelper.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIView (ANSHelper)


/// 控件标识
@property (nonatomic, copy) NSString *ansViewId;

/// 截图当前view
- (UIImage *)ansSnapshotImage;

/// 控件文本信息
- (NSString *)ansElementText;

- (NSString *)eg_varA;
- (NSString *)eg_varB;
- (NSString *)eg_varC;
- (NSString *)eg_varE;

@end
