//
//  AllBurySecondVC.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/20.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "AllBurySecondVC.h"
#import "AllBuryThirdVC.h"

@interface AllBurySecondVC ()
- (IBAction)to_all_bury_third:(id)sender;

@end

@implementation AllBurySecondVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSStringFromClass([self class]);
}

- (IBAction)to_all_bury_third:(id)sender {
    AllBuryThirdVC *allBuryThirdVC = [[AllBuryThirdVC alloc] init];
    [self.navigationController pushViewController:allBuryThirdVC animated:YES];
}
@end
