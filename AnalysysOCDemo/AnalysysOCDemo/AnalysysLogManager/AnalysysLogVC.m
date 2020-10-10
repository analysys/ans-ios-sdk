//
//  AnalysysLogVC.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/27.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "AnalysysLogVC.h"
#import "AnalysysLogCell.h"
#import "AnalysysLogDetailVC.h"
#import "AnalysysLogManager.h"
@interface AnalysysLogVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,weak) UITableView *ans_table;
@end

@implementation AnalysysLogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goToBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UITableView *table = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;
    [table registerNib:[UINib nibWithNibName:@"AnalysysLogCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AnalysysLogCell"];
    [self.view addSubview:table];
    self.ans_table = table;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [AnalysysLogData sharedSingleton].logData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AnalysysLogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnalysysLogCell" forIndexPath:indexPath];
    NSDictionary *dic = [[AnalysysLogData sharedSingleton].logData objectAtIndex:indexPath.row];
    cell.xwhat_lab.text = [dic objectForKey:@"xwhat"];
    
    long long time = [[dic objectForKey:@"xwhen"] longLongValue];
    cell.xwhen_lab.text = [AnalysysLogData getCurrentDate:[NSDate dateWithTimeIntervalSince1970:time/1000]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = [[AnalysysLogData sharedSingleton].logData objectAtIndex:indexPath.row];
    AnalysysLogDetailVC *detail = [[AnalysysLogDetailVC alloc] init];
    detail.logDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)goToBack {
    [self dismissViewControllerAnimated:YES completion:^{
        [AnalysysLogManager sharedSingleton].button.enabled = YES;
    }];
}


@end
