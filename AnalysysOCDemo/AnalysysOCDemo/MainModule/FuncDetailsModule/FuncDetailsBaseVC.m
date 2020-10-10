//
//  FuncDetailsBaseVC.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/20.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "FuncDetailsBaseVC.h"

@interface FuncDetailsBaseVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,weak) UITableView *table;

@end

@implementation FuncDetailsBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.data addObjectsFromArray:[self getModuleData]];
    
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SuperProtertyCell"];
    [self.view addSubview:table];
    self.table = table;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuperProtertyCell"];
    cell.textLabel.text = [self.data objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (NSMutableArray *)data {
    if (!_data) {
        _data = [NSMutableArray array];
    }
    return _data;
}

- (NSArray *)getModuleData {
    return nil;
}

@end
