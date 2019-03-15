//
//  ThirdViewController.m
//  EGAnalyticsDemo
//
//  Created by analysys on 2018/2/3.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "NextViewController.h"
#import "AnalysysAgent.h"
#import "ANSDatabase.h"
#import "ANSDemoViewController.h"

@interface NextViewController ()
{
        dispatch_queue_t _serialQueue; //  数据队列
}

@property (nonatomic, strong) ANSDatabase *dbHelper;

@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *serialLabel = [NSString stringWithFormat:@"com.analysys.serialQueue"];
    _serialQueue = dispatch_queue_create([serialLabel UTF8String], DISPATCH_QUEUE_SERIAL);
    
     [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"UserAgent" options:NSKeyValueObservingOptionNew || NSKeyValueChangeOldKey context:nil];
    
    _dbHelper = [[ANSDatabase alloc] initWithDatabaseName:@"ANALYSYS.db"];
}

- (void)dealloc {
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"UserAgent"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"UserAgent"]) {
        NSLog(@"UserAgent发生了改变");
    }
}

/** 串行队列 */
- (void)dispatchOnSerialQueue:(void(^)(void))dispatchBlock {
    dispatch_async(_serialQueue, ^{
        dispatchBlock();
    });
}

- (IBAction)userAgentTest:(id)sender {
    NSString *hybridId = @" AnalysysAgent/Hybrid";
    NSString *agentKey = @"UserAgent";
    UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *userAgent = [web stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    userAgent = [userAgent stringByAppendingString:hybridId];
    NSDictionary *userAgentDict = @{agentKey: userAgent};
    //  将字典内容注册到NSUserDefaults中
    [[NSUserDefaults standardUserDefaults] registerDefaults:userAgentDict];
    web = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.ignoredAutoCollection) {
        [AnalysysAgent pageView:@"page:自定义页面事件"];
    }
//
//    NSDictionary *properties = @{@"tag": @"新闻标签", @"pageName":@"首页"};
//    [AnalysysAgent pageView:@"HomePage" properties:properties];
}

- (IBAction)backRootVC:(id)sender {
//    [self.navigationController popToRootViewControllerAnimated:YES];
    ANSDemoViewController *vc = [[ANSDemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)addData:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 30; i++) {
            NSMutableDictionary *dic = [self dataInfo];
            dic[@"xcontext"][@"number"] = [NSNumber numberWithInt:i];
            [_dbHelper insertRecordObject:dic type:0];
        }
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 10; i++) {
            NSMutableDictionary *dic = [self dataInfo];
            dic[@"xcontext"][@"number"] = [NSNumber numberWithInt:i];
            [_dbHelper insertRecordObject:dic type:0];
        }
    });
    
    [self dispatchOnSerialQueue:^{
        for (int i = 0; i < 20; i++) {
            NSMutableDictionary *dic = [self dataInfo];
            dic[@"xcontext"][@"tempNumber"] = [NSNumber numberWithInt:i];
            [_dbHelper insertRecordObject:dic type:0];
        }
    }];
}

- (IBAction)deleteData:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_dbHelper deleteTopRecords:10 type:@"0"];
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_dbHelper deleteTopRecords:6 type:@"0"];
    });
}

- (IBAction)queryData:(id)sender {
    NSArray *data = [_dbHelper getTopRecords:10 type:0];
    NSLog(@"--------");
    NSLog(@"%@", data);
    NSLog(@"--------");
    
    NSArray *data1 = [_dbHelper getTopRecords:10 type:0];
    NSLog(@"--------");
    NSLog(@"%@", data1);
    NSLog(@"--------");
}

- (IBAction)dataCount:(id)sender {
    NSInteger dataCount = [_dbHelper recordRows];
    NSLog(@"dataCount----------%ld", dataCount);
}

- (NSMutableDictionary *)dataInfo {
    NSMutableDictionary *dataInfo = [NSMutableDictionary dictionary];
    dataInfo[@"xwho"] = @"1212qw";
    dataInfo[@"xwhen"] = @10001010010;
    dataInfo[@"xwhat"] = @"action";
    dataInfo[@"appid"] = @"1f1956cb7d4013de";
    dataInfo[@"xcontext"] = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value1",@"key1",@"value2",@"key2", nil];
    return dataInfo;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
