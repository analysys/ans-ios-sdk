//
//  MainModuleVC.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/17.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "MainModuleVC.h"
#import "ANSConfigVC.h"

#import "SuperProtertyVC.h"
#import "PageViewVC.h"
#import "AllBuryVC.h"
#import "HeatMapVC.h"
#import "VisualVC.h"
#import "TrackingVC.h"
#import "UserIDWithPropertyVC.h"
#import "HybridVC.h"
#import "OtherVC.h"

@interface MainModuleVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,weak) UITableView *main_table;
@property (nonatomic,strong) NSMutableArray *main_data;
@end

@implementation MainModuleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"易观方舟 Demo";
    
    [self.main_data addObjectsFromArray:[self getMainModuleData]];
    UITableView *main_table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStyleGrouped];
    main_table.delegate = self;
    main_table.dataSource = self;
    [main_table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MainModuleCell"];
    [self.view addSubview:main_table];
    self.main_table = main_table;
    
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"修改配置" style:UIBarButtonItemStylePlain target:self action:@selector(changeConfig)];
    self.navigationItem.rightBarButtonItems = @[rightItem];
}

- (void)changeConfig {
    ANSConfigVC *config = [[ANSConfigVC alloc] init];
    config.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:config animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainModuleCell"];
    cell.textLabel.text = [self.main_data objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.main_data.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *mainModuleCase = [self.main_data objectAtIndex:indexPath.row];
    
    if ([mainModuleCase isEqualToString:SuperProperty]) {
        
        SuperProtertyVC *superProtertyVC = [[SuperProtertyVC alloc] init];
        superProtertyVC.title = mainModuleCase;
        [self.navigationController pushViewController:superProtertyVC animated:YES];
        
    } else if ([mainModuleCase isEqualToString:PageView]) {
        
        PageViewVC *pageViewVC = [[PageViewVC alloc] init];
        pageViewVC.title = mainModuleCase;
        [self.navigationController pushViewController:pageViewVC animated:YES];
        
    } else if ([mainModuleCase isEqualToString:AllBury]) {
        
        AllBuryVC *allBuryVC = [[AllBuryVC alloc] init];
        allBuryVC.title = mainModuleCase;
        [self.navigationController pushViewController:allBuryVC animated:YES];
           
    } else if ([mainModuleCase isEqualToString:HeatMap]) {
        
        HeatMapVC *heatMapVC = [[HeatMapVC alloc] init];
        heatMapVC.title = mainModuleCase;
        [self.navigationController pushViewController:heatMapVC animated:YES];
           
    } else if ([mainModuleCase isEqualToString:Visual]) {
           
        VisualVC *visualVC = [[VisualVC alloc] init];
        visualVC.title = mainModuleCase;
        [self.navigationController pushViewController:visualVC animated:YES];
        
    } else if ([mainModuleCase isEqualToString:Tracking]) {
        
        TrackingVC *trackingVC = [[TrackingVC alloc] init];
        trackingVC.title = mainModuleCase;
        [self.navigationController pushViewController:trackingVC animated:YES];
           
    } else if ([mainModuleCase isEqualToString:UserIDWithProperty]) {
        
        UserIDWithPropertyVC *userIDWithPropertyVC = [[UserIDWithPropertyVC alloc] init];
        userIDWithPropertyVC.title = mainModuleCase;
        [self.navigationController pushViewController:userIDWithPropertyVC animated:YES];
           
    } else if ([mainModuleCase isEqualToString:Hybrid]) {
        
        HybridVC *hybridVC = [[HybridVC alloc] init];
        hybridVC.title = mainModuleCase;
        [self.navigationController pushViewController:hybridVC animated:YES];
        
    } else if ([mainModuleCase isEqualToString:Other]) {
        
        OtherVC *otherVC = [[OtherVC alloc] init];
        otherVC.title = mainModuleCase;
        [self.navigationController pushViewController:otherVC animated:YES];
        
    } else {
        
    }
    
}

- (NSMutableArray *)main_data {
    if (!_main_data) {
        _main_data = [NSMutableArray array];
    }
    return _main_data;;
}

- (NSArray *)getMainModuleData {
    //获取文件路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"main_module" ofType:@"json"];
    //获取文件内容
    NSString *jsonStr  = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    //将文件内容转成数据
    NSData *jaonData   = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    //将数据转成数组
    NSMutableArray *arr = [NSJSONSerialization JSONObjectWithData:jaonData options:NSJSONReadingMutableContainers error:nil];
    
    NSMutableArray *ret = [NSMutableArray array];
    
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [ret addObject:[obj.allKeys firstObject]];
    }];
    return ret;
}

@end
