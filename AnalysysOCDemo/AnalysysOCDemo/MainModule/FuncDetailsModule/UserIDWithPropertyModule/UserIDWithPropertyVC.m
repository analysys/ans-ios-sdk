//
//  UserIDWithPropertyVC.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/20.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "UserIDWithPropertyVC.h"

static NSString *const set_user_id = @"设置匿名ID";
static NSString *const set_alias_id = @"匿名ID与用户关联";
static NSString *const get_distinct_id = @"获取匿名ID";
static NSString *const set_multi_user_propertis = @"设置多个用户属性";
static NSString *const set_single_user_propertis = @"设置单个用户属性";
static NSString *const set_multi_once_propertis = @"设置多个固有属性";
static NSString *const set_single_once_propertis = @"设置单个固有属性";
static NSString *const set_multi_increment_propertis = @"设置多个相对变化值";
static NSString *const set_single_increment_propertis = @"设置单个相对变化值";
static NSString *const append_multi_user_propertis = @"追加多个用户属性";
static NSString *const append_single_user_propertis = @"追加单个用户属性";
static NSString *const delete_single_user_propertis = @"删除单个用户属性";
static NSString *const delete_all_user_propertis = @"删除所有用户属性";

@interface UserIDWithPropertyVC ()

@end

@implementation UserIDWithPropertyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *str = [self.data objectAtIndex:indexPath.row];
    
    if ([str isEqualToString:set_user_id]) {
        
        //用户ID设置
        NSString *distinct_id = @"WeChatID_1";
        [AnalysysAgent identify:distinct_id];
        [self showTitle:str message:[NSString stringWithFormat:@"当前标识:%@",distinct_id]];
        
    } else if ([str isEqualToString:set_alias_id]) {
        
        //alias用户关联:18688886666
        [AnalysysAgent alias:@"18688886666"];
        [self showTitle:str message:@"当前身份标识：18688886666"];
        
    } else if ([str isEqualToString:get_distinct_id]) {
        
        //获取匿名ID
        NSString *distinctId = [AnalysysAgent getDistinctId];
        [self showTitle:str message:[NSString stringWithFormat:@"匿名ID:%@",distinctId]];
        
    } else if ([str isEqualToString:set_multi_user_propertis]) {
        
        //设置多个用户属性
        NSDictionary *properties = @{@"nickName":@"小叮当",@"Hobby":@[@"Singing", @"Dancing"]};
        [AnalysysAgent profileSet:properties];
        [self showTitle:str message:[AnalysysJson convertToStringWithObject:properties]];
        
    } else if ([str isEqualToString:set_single_user_propertis]) {
        
        //设置单个用户属性
        [AnalysysAgent profileSet:@"Job" propertyValue:@"Engineer"];
        [self showTitle:str message:@"Job: Engineer"];
        
    } else if ([str isEqualToString:set_multi_once_propertis]) {
        
        //设置多个固有属性
        NSDictionary *properties = @{@"activationTime": @"1521594686781", @"loginTime": @"1521594792345"};
        [AnalysysAgent profileSetOnce:properties];
        [self showTitle:str message:[AnalysysJson convertToStringWithObject:properties]];
        
    } else if ([str isEqualToString:set_single_once_propertis]) {
        
        //设置单个固有属性
        [AnalysysAgent profileSetOnce:@"Birthday" propertyValue:@"1995-01-01"];
        [self showTitle:str message:@"Birthday: 1995-01-01"];
        
    } else if ([str isEqualToString:set_multi_increment_propertis]) {
        
        //设置多个相对变化值
        NSDictionary *dic = @{@"LoginCount": [NSNumber numberWithInt:1],@"Point": [NSNumber numberWithInt:10]};
        [AnalysysAgent profileIncrement:dic];
        [self showTitle:str message:[AnalysysJson convertToStringWithObject:dic]];
        
    } else if ([str isEqualToString:set_single_increment_propertis]) {
        
        //设置单个相对变化值
        [AnalysysAgent profileIncrement:@"UseCount" propertyValue:@(10)];
        [self showTitle:str message:@"UseCount: 10"];
        
    } else if ([str isEqualToString:append_multi_user_propertis]) {
        
        //追加多个用户属性
        [AnalysysAgent profileAppend:@{@"Books": @[@"西游记", @"三国演义"],@"Drinks": @"orange juice"}];
        [self showTitle:str message:@"Books: 西游记,三国演义；Drinks：orange juice"];
        
    } else if ([str isEqualToString:append_single_user_propertis]) {
        
        //追加单个用户属性
        [AnalysysAgent profileAppend:@"clothes" propertyValue:[NSSet setWithObjects:@"pants", @"T-shirt", nil]];
        [self showTitle:str message:@"clothes: pants,T-shirt"];
        
    } else if ([str isEqualToString:delete_single_user_propertis]) {
        
        //删除单个用户属性
        [AnalysysAgent profileUnset:@"clothes"];
        [self showTitle:str message:@"clothes"];
        
    } else if ([str isEqualToString:delete_all_user_propertis]) {
        
        //清除所有用户属性
        [AnalysysAgent profileDelete];
        [self showTitle:str message:@""];
        
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
        if ([(NSString *)obj.allKeys.firstObject isEqualToString:UserIDWithProperty]) {
            ret = [NSMutableArray arrayWithArray:[obj objectForKey:UserIDWithProperty]];
            *stop = YES;
        }
    }];
    return ret;
}

@end
