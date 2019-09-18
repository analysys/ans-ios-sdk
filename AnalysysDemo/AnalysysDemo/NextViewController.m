//
//  ThirdViewController.m
//  EGAnalyticsDemo
//
//  Created by analysys on 2018/2/3.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "NextViewController.h"
#import <AnalysysAgent/AnalysysAgent.h>
#import "PopViewController.h"
#import "BaseNavViewController.h"

@interface NextViewController ()
@property (weak, nonatomic) IBOutlet UITextField *appKeyTF;
@property (weak, nonatomic) IBOutlet UITextField *domainTF;

@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    NSLog(@"++++++++");
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.ignoredAutoCollection) {
        [AnalysysAgent pageView:@"手动调用页面采集"];
    }
}

- (IBAction)backRootVC:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
