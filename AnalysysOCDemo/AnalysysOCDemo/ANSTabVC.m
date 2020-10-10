//
//  ANSTabVC.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/17.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "ANSTabVC.h"
#import "FastExperienceVC.h"
#import "MainModuleVC.h"

@interface ANSTabVC ()

@end

@implementation ANSTabVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    FastExperienceVC *oneVC = [[FastExperienceVC alloc] init];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:oneVC];
    nav1.tabBarItem.title = @"快速体验";
    [self addChildViewController:nav1];
    
    
    MainModuleVC *twoVC = [[MainModuleVC alloc] init];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:twoVC];
    nav2.tabBarItem.title = @"功能详情";
    [self addChildViewController:nav2];
    
}

@end
