//
//  ANSBindTableViewVC.m
//  AnalysysSDKDemo
//
//  Created by xiao xu on 2020/2/5.
//  Copyright © 2020 shaochong du. All rights reserved.
//

#import "ANSBindTableViewVC.h"
#import "ANSBindTableViewCell.h"
#import "ANSTableHeaderFooterView.h"
@interface ANSBindTableViewVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,weak) UITableView *bindTableView;
@end

@implementation ANSBindTableViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITableView *bindTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStyleGrouped];
    bindTableView.allowsMultipleSelection = YES;
    [bindTableView registerNib:[UINib nibWithNibName:@"ANSBindTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ANSBindTableViewCell"];
    [bindTableView registerNib:[UINib nibWithNibName:@"ANSTableHeaderFooterView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"ANSTableHeaderFooterView"];
    bindTableView.delegate = self;
    bindTableView.dataSource = self;
    [self.view addSubview:bindTableView];
    self.bindTableView = bindTableView;
    
}

- (void)click {
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ANSBindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ANSBindTableViewCell" forIndexPath:indexPath];
    cell.ans_titleLab.text = [NSString stringWithFormat:@"section:%ld-row:%ld", indexPath.section, indexPath.row];
    [cell.ans_clickBtn setTitle:[NSString stringWithFormat:@"zan-%ld",indexPath.row] forState:UIControlStateNormal];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ANSTableHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ANSTableHeaderFooterView"];
    header.titleLabel.text = [NSString stringWithFormat:@"SectionHeader:%ld",section];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ANSTableHeaderFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ANSTableHeaderFooterView"];
    footer.titleLabel.text = [NSString stringWithFormat:@"SectionFooter:%ld",section];
    return footer;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
}

@end
