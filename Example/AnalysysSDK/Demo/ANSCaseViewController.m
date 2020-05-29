//
//  ANSCaseViewController.m
//  AnalysysSDK-iOS
//
//  Created by SoDo on 2019/3/13.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSCaseViewController.h"
#import "AnalysysAgent.h"
#import "ANSDemoTableViewCell.h"
#import "ANSSearchTableViewController.h"
#import "ANSTableHeaderFooterView.h"

static NSString *cellIdenfity = @"ANSDemoTableViewCell";
static NSString *headerViewIdentify = @"HeaderView";

@interface ANSCaseViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic,copy)NSArray* dataSource;
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation ANSCaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.title = @"列表测试";
    self.navigationItem.titleView = [self customerTitleView];

    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
//    self.tableView.tableHeaderView = [self headerView];
//    if(@available(iOS 11.0, *)) {
//        self.navigationItem.searchController = self.searchController;
//        self.navigationItem.hidesSearchBarWhenScrolling = YES;
//        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    } else {
        self.tableView.tableHeaderView = self.searchController.searchBar;
        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
    [self.tableView registerNib:[UINib nibWithNibName:@"ANSDemoTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdenfity];

    [self.tableView registerNib:[UINib nibWithNibName:@"ANSTableHeaderFooterView" bundle:nil] forHeaderFooterViewReuseIdentifier:headerViewIdentify];
}

- (UIView *)headerView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
    view.backgroundColor = [UIColor redColor];
    return view;
}



- (UIView *)customerTitleView {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 100, 30);
    [btn setBackgroundColor:[UIColor magentaColor]];
    [btn setTitle:@"自定义标题" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(touchTitle) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 80, 30)];
    label.text = @"列表测试";
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor orangeColor];
    [bgView addSubview:label];

    return bgView;
}

- (void)touchTitle {
    NSLog(@"点击标题");
}

- (UISearchController *)searchController {
    if (!_searchController) {
        ANSSearchTableViewController *searchVC = [[ANSSearchTableViewController alloc] init];
        _searchController = [[UISearchController alloc] initWithSearchResultsController:searchVC];
        _searchController.delegate = searchVC;
        _searchController.searchResultsUpdater = searchVC;
        _searchController.searchBar.frame=CGRectMake(0,0,_searchController.searchBar.frame.size.width,44.0);
    }
    return _searchController;
}

#pragma mark -----------------搜索栏代理--------------------

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // 修改UISearchBar右侧的取消按钮文字颜色及背景图片
    for (id searchbuttons in [[searchBar subviews][0]subviews]) //只需在此处修改即可
        if ([searchbuttons isKindOfClass:[UIButton class]]) {
            UIButton *cancelButton = (UIButton *)searchbuttons;
            // 修改文字颜色
            [cancelButton setTitle:@"取消"forState:UIControlStateNormal];
        }
}

#pragma mark  -------searchbarDelegate------
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
}

#pragma mark - source data

-(NSArray *)dataSource {
    if (!_dataSource) {
        NSMutableArray* mutDataArr = [NSMutableArray array];
        [mutDataArr addObject:@[@"track_cell"]];
        [mutDataArr addObject:@[@"pageview_cell"]];
        [mutDataArr addObject:@[@"alias_cell"]];
        [mutDataArr addObject:@[@"superProperty_cell"]];
        [mutDataArr addObject:@[@"profileSet_cell"]];
        [mutDataArr addObject:@[@"profileSetOnce_cell"]];
        [mutDataArr addObject:@[@"profileIncrement_cell"]];
        [mutDataArr addObject:@[@"profileAppend_cell"]];
        
        _dataSource = mutDataArr.copy;
    }
    return _dataSource;
}

- (NSArray *)titleArr {
    return @[@"track",@"pageView",@"alias",@"superProerty",@"profileSet",@"profileSetOnce",@"profileIncrement",@"profileAppend"];
}

#pragma mark - tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ANSDemoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdenfity];
    cell.titleLabel.text = self.dataSource[indexPath.section][indexPath.row];
    [cell.detailBtn setTitle:[NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row] forState:UIControlStateNormal];
//
//    static NSString *cellIdentify = @"cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.frame =CGRectMake(100, 5, 100, 40);
//        [btn setTitle:@"测试" forState:UIControlStateNormal];
//        [btn setBackgroundColor:[UIColor greenColor]];
//        [cell addSubview:btn];
//    }
//    cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"detail - %ld", indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    ANSTableHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerViewIdentify];
    headerView.titleLabel.text = self.titleArr[section];
    
    return headerView;
}


@end
