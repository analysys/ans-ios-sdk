//
//  EGBaseViewController.m
//  EGAnalyticsDemo
//
//  Created by analysys on 2018/2/5.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "EGBaseViewController.h"
#import "UIView+KeyboardAnimation.h"

@interface EGBaseViewController ()

@end

@implementation EGBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //  设置键盘遮挡
    [self.view addKeyboardNotification];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - 键盘遮挡
- (void)dealloc {
    [self.view removeKeyboardNotification];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [[self.view getIsEditingText] resignFirstResponder];
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
