//
//  SuperProtertyVC.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/20.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "SuperProtertyVC.h"

static NSString *const register_super_properties = @"注册多个通用属性";
static NSString *const get_super_property = @"获取单个通用属性";
static NSString *const register_single_super_properties = @"注册单个通用属性";
static NSString *const un_register_super_property = @"删除单个通用属性";
static NSString *const clear_super_properties = @"删除所有通用属性";
static NSString *const get_all_super_properties = @"获取所有通用属";

@interface SuperProtertyVC ()

@end

@implementation SuperProtertyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *str = [self.data objectAtIndex:indexPath.row];
    if ([str isEqualToString:register_super_properties]) {
        NSDictionary *dic = @{@"property1" : @"one", @"property2" : @"two"};
        [AnalysysAgent registerSuperProperties:dic];
        [self showTitle:str message:[AnalysysJson convertToStringWithObject:dic]];
    } else if ([str isEqualToString:get_super_property]) {
        id property = [AnalysysAgent getSuperProperty:@"property1"];
        [self showTitle:str message:[NSString stringWithFormat:@"property1 - %@", property]];
    } else if ([str isEqualToString:register_single_super_properties]) {
        [AnalysysAgent registerSuperProperty:@"age" value:@(18)];
        [self showTitle:str message:@"age - 18"];
    } else if ([str isEqualToString:un_register_super_property]) {
        [AnalysysAgent unRegisterSuperProperty:@"property2"];
        [self showTitle:str message:@"property2"];
    } else if ([str isEqualToString:clear_super_properties]) {
        [AnalysysAgent clearSuperProperties];
        [self showTitle:str message:@""];
    } else if ([str isEqualToString:get_all_super_properties]) {
        NSDictionary *dic = [AnalysysAgent getSuperProperties];
        [self showTitle:str message:[AnalysysJson convertToStringWithObject:dic]];
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
        if ([(NSString *)obj.allKeys.firstObject isEqualToString:SuperProperty]) {
            ret = [NSMutableArray arrayWithArray:[obj objectForKey:SuperProperty]];
            *stop = YES;
        }
    }];
    return ret;
}

@end
