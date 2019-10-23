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

- (UIImage *)AnsSnapshotImage;
- (UIImage *)AnsSnapshotForBlur;
- (NSString *)AnsElementText;

- (NSString *)eg_varA;
- (NSString *)eg_varB;
- (NSString *)eg_varC;
- (NSString *)eg_varE;

@end
