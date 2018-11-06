//
//  ThirdViewController.m
//  EGAnalyticsDemo
//
//  Created by analysys on 2018/2/3.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "NextViewController.h"
#import <AnalysysAgent/AnalysysAgent.h>

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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.ignoredAutoCollection) {
        [AnalysysAgent pageView:@"手动调用页面采集"];
    }
}

- (IBAction)backRootVC:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)modifyAppKeyAction:(id)sender {
    if (self.appKeyTF.text.length > 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.appKeyTF.text forKey:@"EGAppKey"];
        [defaults synchronize];
        [self showTips];
    }
}

- (IBAction)modifyDomainAction:(id)sender {
    if (self.domainTF.text.length > 0) {
//        [AnalysysAgent setUploadURL:[NSString stringWithFormat:@"http://%@",self.domainTF.text]];
        [AnalysysAgent setVisitorDebugURL:[NSString stringWithFormat:@"ws://%@",self.domainTF.text]];
//        [AnalysysAgent setVisitorConfigURL:[NSString stringWithFormat:@"http://%@",self.domainTF.text]];
        [self showTips];
    }
}

- (void)showTips {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"tip" message:@"修改完成" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"OK");
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
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
