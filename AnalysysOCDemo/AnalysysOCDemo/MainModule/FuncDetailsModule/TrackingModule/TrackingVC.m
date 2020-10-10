//
//  TrackingVC.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/20.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "TrackingVC.h"

static NSString *const tracking_event = @"统计事件";
static NSString *const tracking_event_with_properties = @"统计事件带属性";

@interface TrackingVC ()

@end

@implementation TrackingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *str = [self.data objectAtIndex:indexPath.row];
    
    if ([str isEqualToString:tracking_event]) {
        [AnalysysAgent track:@"tracking_event"];
        [self showTitle:str message:@"事件:tracking_event"];
    } else if ([str isEqualToString:tracking_event_with_properties]) {
        NSDictionary *dic = @{@"name" : @"analysys", @"age" : @(18)};
        [AnalysysAgent track:@"tracking_event_with_properties" properties:dic];
        [self showTitle:str message:[NSString stringWithFormat:@"事件:tracking_event_with_properties | 属性:%@",[AnalysysJson convertToStringWithObject:dic]]];
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
        if ([(NSString *)obj.allKeys.firstObject isEqualToString:Tracking]) {
            ret = [NSMutableArray arrayWithArray:[obj objectForKey:Tracking]];
            *stop = YES;
        }
    }];
    return ret;
}

@end
