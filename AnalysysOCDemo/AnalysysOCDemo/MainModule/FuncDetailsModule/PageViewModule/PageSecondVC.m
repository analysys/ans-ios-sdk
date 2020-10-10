//
//  PageSecondVC.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/20.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "PageSecondVC.h"
#import "PageThirdVC.h"
@interface PageSecondVC ()
- (IBAction)to_page_third:(id)sender;

@end

@implementation PageSecondVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSStringFromClass([self class]);
}

- (IBAction)to_page_third:(id)sender {
    PageThirdVC *pageThirdVC = [[PageThirdVC alloc] init];
    [self.navigationController pushViewController:pageThirdVC animated:YES];
}
@end
