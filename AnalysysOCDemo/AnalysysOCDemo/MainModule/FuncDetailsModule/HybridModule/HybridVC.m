//
//  HybridVC.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/20.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "HybridVC.h"
#import "ANSWebViewController.h"
#import "ANSWKWebViewController.h"

static NSString *const hybrid_uiwebview = @"UIWebView";
static NSString *const hybrid_wkwebview = @"WKWebView";

@interface HybridVC ()

@end

@implementation HybridVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *str = [self.data objectAtIndex:indexPath.row];
    
    if ([str isEqualToString:hybrid_uiwebview]) {
        
        ANSWebViewController *ui_web = [[ANSWebViewController alloc] init];
        ui_web.hidesBottomBarWhenPushed = true;
        [self.navigationController pushViewController:ui_web animated:YES];
        
    } else if ([str isEqualToString:hybrid_wkwebview]) {
        
        ANSWKWebViewController *wk_web = [[ANSWKWebViewController alloc] init];
        wk_web.hidesBottomBarWhenPushed = true;
        [self.navigationController pushViewController:wk_web animated:YES];
        
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
        if ([(NSString *)obj.allKeys.firstObject isEqualToString:Hybrid]) {
            ret = [NSMutableArray arrayWithArray:[obj objectForKey:Hybrid]];
            *stop = YES;
        }
    }];
    return ret;
}

@end
