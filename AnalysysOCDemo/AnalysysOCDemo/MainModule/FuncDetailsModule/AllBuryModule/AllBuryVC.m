//
//  AllBuryVC.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/20.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "AllBuryVC.h"
#import "AllBuryFirstVC.h"

static NSString *const all_bury_next_page = @"前往测试页面";
static NSString *const all_bury_black_list_pages = @"忽略部分页面上所有的点击事件";
static NSString *const all_bury_black_list_views = @"忽略某些类名控件点击事件";

@interface AllBuryVC ()

@end

@implementation AllBuryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *str = [self.data objectAtIndex:indexPath.row];
    
    if ([str isEqualToString:all_bury_next_page]) {
        
        AllBuryFirstVC *allBuryFirstVC = [[AllBuryFirstVC alloc] init];
        allBuryFirstVC.hidesBottomBarWhenPushed = true;
        [self.navigationController pushViewController:allBuryFirstVC animated:YES];
        
    } else if ([str isEqualToString:all_bury_black_list_pages]) {
        
        [AnalysysAgent setAutoClickBlackListByPages:[NSSet setWithArray:@[@"AllBuryFirstVC", @"AllBurySecondVC"]]];
        [self showTitle:str message:[AnalysysJson convertToStringWithObject:@[@"AllBuryFirstVC", @"AllBurySecondVC"]]];
        
    } else if ([str isEqualToString:all_bury_black_list_views]) {
        
        [AnalysysAgent setAutoClickBlackListByViewTypes:[NSSet setWithArray:@[@"AnalysysButton", @"AnalysysSwitch"]]];
        [self showTitle:str message:[AnalysysJson convertToStringWithObject:@[@"AnalysysButton", @"AnalysysSwitch"]]];
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
        if ([(NSString *)obj.allKeys.firstObject isEqualToString:AllBury]) {
            ret = [NSMutableArray arrayWithArray:[obj objectForKey:AllBury]];
            *stop = YES;
        }
    }];
    return ret;
}

@end
