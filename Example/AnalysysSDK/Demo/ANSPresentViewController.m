//
//  ANSPresentViewController.m
//  AnalysysSDKDemo
//
//  Created by SoDo on 2019/10/18.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSPresentViewController.h"

@interface ANSPresentViewController ()

@property (nonatomic, strong) UIView *contentView;

@end

@implementation ANSPresentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 150, 40);
    [btn setBackgroundColor:[UIColor magentaColor]];
    [btn setTitle:@"dismiss page" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dismissPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    self.contentView = [[UIView alloc] init];
    self.contentView.frame = CGRectMake(20, 200, self.view.frame.size.width-20*2, self.view.frame.size.height - 400);
    [self.view addSubview:self.contentView];
    [self updateViewBackgroudColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateViewBackgroudColor)];
    [self.contentView addGestureRecognizer:tap];
}

- (void)dismissPage {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateViewBackgroudColor {
    CGFloat red = arc4random() % 255 / 255.0;
    CGFloat green = arc4random() % 255 / 255.0;
    CGFloat blue = arc4random() % 255 / 255.0;
    self.contentView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.5];
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
