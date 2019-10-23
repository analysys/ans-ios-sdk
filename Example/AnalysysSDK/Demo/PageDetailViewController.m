//
//  PageDetailViewController.m
//  AnalysysSDKDemo
//
//  Created by SoDo on 2019/8/21.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "PageDetailViewController.h"
#import "ANSPresentViewController.h"
#import <AnalysysSDK/AnalysysAgent.h>

/** 若使用SDK自动采集功能，遵循protocol <ANSAutoPageTracker>*/
@interface PageDetailViewController ()<ANSAutoPageTracker>

@end

@implementation PageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


/**
 实现ANSAutoPageProtocol协议

 @return 页面自定义参数信息
 */
- (NSDictionary *)registerPageProperties {
    //  $title/$url 为自动采集使用key，用户可覆盖
    //  增加商品标识(productID)
    return @{@"$title": @"详情页", @"$url": @"/homepage/detailpage", @"productID": @"1001"};
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)presentVC:(id)sender {
    ANSPresentViewController *detail = [[ANSPresentViewController alloc] init];
    [self presentViewController:detail animated:YES completion:nil];
}

@end
