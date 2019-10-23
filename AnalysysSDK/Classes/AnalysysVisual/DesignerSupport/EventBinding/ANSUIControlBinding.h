//
//  ANSUIControlBinding.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSEventBinding.h"

#import <UIKit/UIKit.h>

@interface ANSUIControlBinding : ANSEventBinding


@property (nonatomic, readonly) UIControlEvents controlEvent;
@property (nonatomic, readonly) UIControlEvents verifyEvent;

- (instancetype)init __unavailable;


@end
