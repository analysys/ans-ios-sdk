//
//  FastExperienceVC.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/17.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "FastExperienceVC.h"
#import "ANSConfigVC.h"
@interface FastExperienceVC ()
- (IBAction)normal_click:(id)sender;
- (IBAction)event_name_click:(id)sender;
- (IBAction)key_value_click:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *event_name_tf;
@property (weak, nonatomic) IBOutlet UITextField *action_key_tf;
@property (weak, nonatomic) IBOutlet UITextField *action_value_tf;

@end

@implementation FastExperienceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"易观方舟 Demo";
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"修改配置" style:UIBarButtonItemStylePlain target:self action:@selector(changeConfig)];
    self.navigationItem.rightBarButtonItems = @[rightItem];
    
}

- (void)changeConfig {
    ANSConfigVC *config = [[ANSConfigVC alloc] init];
    config.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:config animated:YES];
}


- (IBAction)key_value_click:(id)sender {
    if (self.action_key_tf.text.length == 0 ||
        self.action_value_tf.text.length == 0) {
        [AnalysysHUD showTitle:@"提示" message:@"请输入Key-Value"];
        return;
    }
    
    [AnalysysAgent track:@"custom_key_value" properties:@{self.action_key_tf.text : self.action_value_tf.text}];
    [self showTitle:@"提示" message:[NSString stringWithFormat:@"触发事件:track_property:%@-%@", self.action_key_tf.text, self.action_value_tf.text]];
}

- (IBAction)event_name_click:(id)sender {
    if (self.event_name_tf.text.length == 0) {
        [AnalysysHUD showTitle:@"提示" message:@"请输入自定义事件名称"];
        return;
    }
    [AnalysysAgent track:self.event_name_tf.text];
    [self showTitle:@"提示" message:[NSString stringWithFormat:@"触发事件:%@", self.event_name_tf.text]];
}

- (IBAction)normal_click:(id)sender {
    [AnalysysAgent track:@"track_text"];
    [self showTitle:@"提示" message:@"触发事件"];
}
@end
