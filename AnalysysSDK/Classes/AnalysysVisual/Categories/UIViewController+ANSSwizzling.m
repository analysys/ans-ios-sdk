//
//  UIViewController+ANSSwizzling.m
//  AnalysysAgent
//
//  Created by analysys on 2017/2/22.
//  Copyright © 2017年 Analysys. All rights reserved.
//

#import "UIViewController+ANSSwizzling.h"
#import "NSObject+ANSSwizzling.h"

@implementation UIViewController (ANSSwizzling)

//  处理可视化上传snapshot时 页面正在切换状态
+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIViewController ansExchangeOriginalSel:@selector(viewWillAppear:)
                                       replacedSel:@selector(ans_ViewWillAppear:)];
        
        [UIViewController ansExchangeOriginalSel:@selector(viewDidAppear:)
                                       replacedSel:@selector(ans_ViewDidAppear:)];
        
        [UIViewController ansExchangeOriginalSel:@selector(viewWillDisappear:)
                                       replacedSel:@selector(ans_ViewWillDisappear:)];
        
        [UIViewController ansExchangeOriginalSel:@selector(viewDidDisappear:)
                                       replacedSel:@selector(ans_ViewDidDisappear:)];
    });
}

#pragma mark - 交换方法
- (void)ans_ViewWillAppear:(BOOL)animated {
    [self ans_ViewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AnalysysPageUnready" object:nil];
}

- (void)ans_ViewDidAppear:(BOOL)animated {
    [self ans_ViewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AnalysysPageReady" object:nil];
}

- (void)ans_ViewWillDisappear:(BOOL)animated {
    [self ans_ViewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AnalysysPageUnready" object:nil];
}

- (void)ans_ViewDidDisappear:(BOOL)animated {
    [self ans_ViewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AnalysysPageReady" object:nil];
}



@end
