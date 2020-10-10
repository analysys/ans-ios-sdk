//
//  PageViewVC.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/20.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "PageViewVC.h"
#import "PageFirstVC.h"

static NSString *const pageview_next_page = @"前往自动采集测试页面";
static NSString *const pageview_black_list_pages = @"自动采集忽略某些页面";
static NSString *const pageview_action = @"手动触发页面采集";
static NSString *const pageview_action_property = @"手动触发页面采集带属性";

@interface PageViewVC ()

@end

@implementation PageViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *str = [self.data objectAtIndex:indexPath.row];
    
    if ([str isEqualToString:pageview_next_page]) {
        
        PageFirstVC *pageFirstVC = [[PageFirstVC alloc] init];
        pageFirstVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pageFirstVC animated:YES];
        
    } else if ([str isEqualToString:pageview_black_list_pages]) {
        
        [AnalysysAgent setPageViewBlackListByPages:[NSSet setWithArray:@[@"PageFirstVC", @"PageSecondVC"]]];
        [self showTitle:str message:[AnalysysJson convertToStringWithObject:@[@"PageFirstVC", @"PageSecondVC"]]];
        
    } else if ([str isEqualToString:pageview_action]) {
        
        [AnalysysAgent pageView:@"采集【活动页】"];
        [self showTitle:@"提示" message:@"采集【活动页】"];
        
    } else if ([str isEqualToString:pageview_action_property]) {
        
        NSDictionary *dic = @{@"commodityName" : @"iPhone", @"commodityPrice" : @"8000"};
        [AnalysysAgent pageView:@"采集【商品页】" properties:dic];
        [self showTitle:str message:[NSString stringWithFormat:@"采集【商品页】属性为 %@", [AnalysysJson convertToStringWithObject:dic]]];
        
    }
}

- (NSArray *)getModuleData {
    //获取文件路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"main_module" ofType:@"json"];
    //获取文件内容
    NSString *jsonStr  = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    //将文件内容转成数据
    NSData *jaonData   = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    //将数据转成数组
    NSMutableArray *arr = [NSJSONSerialization JSONObjectWithData:jaonData options:NSJSONReadingMutableContainers error:nil];
    
    __block NSMutableArray * ret;
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([(NSString *)obj.allKeys.firstObject isEqualToString:PageView]) {
            ret = [NSMutableArray arrayWithArray:[obj objectForKey:PageView]];
            *stop = YES;
        }
    }];
    return ret;
}

@end
