//
//  AllBuryFirstVC.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/20.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "AllBuryFirstVC.h"
#import "AllBurySecondVC.h"

@interface AllBuryFirstVC ()
- (IBAction)to_all_bury_second:(id)sender;
- (IBAction)analysys_btn_action:(id)sender;
- (IBAction)analysys_switch_action:(id)sender;
- (IBAction)analysys_seg_action:(id)sender;
- (IBAction)anlysys_step_action:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lab_gesture;

@end

@implementation AllBuryFirstVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSStringFromClass([self class]);
    
    self.lab_gesture.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(label_tap_action)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.lab_gesture addGestureRecognizer:tap];
}


- (IBAction)anlysys_step_action:(id)sender {
}

- (IBAction)analysys_seg_action:(id)sender {
}

- (IBAction)analysys_switch_action:(id)sender {
    
    [AnalysysHUD showTitle:@"提示" message:@"AnalysysSwitch - click"];
}

- (IBAction)analysys_btn_action:(id)sender {
    
    [AnalysysHUD showTitle:@"提示" message:@"AnalysysButton - click"];
}

- (IBAction)to_all_bury_second:(id)sender {
    AllBurySecondVC *allBurySecondVC = [[AllBurySecondVC alloc] init];
    [self.navigationController pushViewController:allBurySecondVC animated:YES];
}

- (void)label_tap_action {
    
}
@end
