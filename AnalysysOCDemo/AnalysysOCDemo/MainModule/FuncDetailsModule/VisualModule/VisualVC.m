//
//  VisualVC.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/20.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "VisualVC.h"
#import "ANSBindNormalVC.h"
#import "ANSBindTableViewVC.h"
#import "ANSBindCollectionViewVC.h"

static NSString *const visual_general_ui = @"常用控件";
static NSString *const visual_table_view = @"列表布局";
static NSString *const visual_collection_view = @"网格布局";

@interface VisualVC ()

@end

@implementation VisualVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *str = [self.data objectAtIndex:indexPath.row];
    
    if ([str isEqualToString:visual_general_ui]) {
        
        ANSBindNormalVC *bindNormalVC = [[ANSBindNormalVC alloc] init];
        bindNormalVC.hidesBottomBarWhenPushed = true;
        [self.navigationController pushViewController:bindNormalVC animated:YES];
        
    } else if ([str isEqualToString:visual_table_view]) {
        
        ANSBindTableViewVC *bindTableViewVC = [[ANSBindTableViewVC alloc] init];
        bindTableViewVC.hidesBottomBarWhenPushed = true;
        [self.navigationController pushViewController:bindTableViewVC animated:YES];
        
    } else if ([str isEqualToString:visual_collection_view]) {
        
        ANSBindCollectionViewVC *bindCollectionViewVC = [[ANSBindCollectionViewVC alloc] init];
        bindCollectionViewVC.hidesBottomBarWhenPushed = true;
        [self.navigationController pushViewController:bindCollectionViewVC animated:YES];
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
        if ([(NSString *)obj.allKeys.firstObject isEqualToString:Visual]) {
            ret = [NSMutableArray arrayWithArray:[obj objectForKey:Visual]];
            *stop = YES;
        }
    }];
    return ret;
}

@end
