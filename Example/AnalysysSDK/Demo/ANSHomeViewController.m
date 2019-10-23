//
//  ViewController.m
//  EGAnalyticsDemo
//
//  Created by analysys on 2018/2/3.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "ANSHomeViewController.h"

#import <AnalysysSDK/AnalysysAgent.h>
#import "ANSTouchId.h"

#import "UIView+MGO.h"

#import "ANSTextField.h"

#import "NextViewController.h"

#import <LocalAuthentication/LocalAuthentication.h>



@interface ANSHomeViewController ()<ANSAutoPageTracker>

@property (weak, nonatomic) IBOutlet ANSTextField *textField;
@property (weak, nonatomic) IBOutlet ANSTextField *custTF;
@property (weak, nonatomic) IBOutlet ANSTextField *keyTextField;
@property (weak, nonatomic) IBOutlet ANSTextField *valueTextField;
@property (weak, nonatomic) IBOutlet ANSTextField *propertyCountTextField;
@property(nonatomic,strong) LAContext *LAContent;

@property (nonatomic, strong) NSTimer *timer;


@end

@implementation ANSHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

#pragma mark - ANSAutoPageTracker

- (NSDictionary *)registerPageProperties {
    return @{@"$title": @"自定义首页标题", @"tag": @[@"iphone", @"white"]};
}

- (NSString *)registerPageUrl {
    return @"HomePage";
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
   [self.view endEditing:YES];  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%s", __FUNCTION__);
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"%s", __FUNCTION__);
}

-(void)dealloc {
    [self.timer invalidate];
}

#pragma mark - action

- (IBAction)buyAction:(id)sender {
    [self purchaseGoods];
    
    [self.view endEditing:YES];
}

- (void)purchaseGoods {
    NSInteger eventCount = 1;
    if (self.textField.text.length == 0) {
        eventCount = 1;
    } else {
        NSInteger count = [self.textField.text integerValue];
        if (count > 100) {
            eventCount = 100;
        } else {
            eventCount = count;
        }
    }
    
    for (int i = 0; i < eventCount; i++) {
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        //        attr[[NSNumber numberWithInt:1]] = @"21";
        attr[@"PayType"] = @"Alipay";   //  支付方式
        attr[@"Price"] = @160.8;    //  价格
        attr[@"Price"] = [NSNumber numberWithFloat:100.9];
        attr[@"Goods"] = @[@"电脑", @"手机"];   //  商品
        attr[@"HasStock"] = @NO;    //  是否有库存
        attr[@"DeliveryDate"] = [NSDate dateWithTimeIntervalSinceNow:7*24*60*60];    //  送达日期
        attr[@"Url"] = [NSURL URLWithString:@"http://www.baidu.com"];
        attr[@"Set"] = [NSSet setWithObjects:@"set1",@"我是一个粉刷匠，粉刷本领强.", nil];
        attr[@"array"] = [NSArray arrayWithObjects:@"123",@"aaaa", nil];
        [AnalysysAgent track:@"purchase" properties:attr];
    }
}


- (IBAction)addEvent:(id)sender {
    if (self.custTF.text.length > 0) {
        [AnalysysAgent track:self.custTF.text properties:@{@"trackTestKey":@[@"trackValue1",@"trackValue2"]}];
    } else {
        [self showAlertView:@"请填写事件名称"];
    }
//    [[ANSTouchId sharedInstance] lzw_showTouchIDWithDescribe:@"touchid" BlockState:^(LzwTouchIDState state, NSError * _Nonnull error) {
//        NSLog(@"-- %lu --", (unsigned long)state);
//    }];
    
//    [[ANSTouchId sharedInstance] lzw_showFaceIDWithDescribe:@"faceid" BlockState:^(TDFaceIDState state, NSError * _Nonnull error) {
//        NSLog(@"faceid-%lu", (unsigned long)state);
//    }];
    [self.view endEditing:YES];
}

- (IBAction)addProperties:(id)sender {
    NSString *key = self.keyTextField.text;
    NSString *value = self.valueTextField.text;
    if (key.length == 0) {
        [self showAlertView:@"请填写属性key"];
        return;
    }
    if (value.length == 0) {
        [self showAlertView:@"请填写属性value"];
        return;
    }
    [AnalysysAgent track:@"customerProperties" properties:@{key:value}];
    
    [self.view endEditing:YES];
}

- (IBAction)multiPropertiesAction:(id)sender {
    NSInteger count = [self.propertyCountTextField.text integerValue];
    if (count > 200) {
        [self showAlertView:@"属性个数不能超过200"];
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *key = self.keyTextField.text;
    NSString *value = self.valueTextField.text;
    if (key.length == 0) {
        [self showAlertView:@"请填写属性key"];
        return;
    }
    if (value.length == 0) {
        [self showAlertView:@"请填写属性value"];
        return;
    }
    
    for (int i = 0; i < count; i++) {
        NSString *key1 = [NSString stringWithFormat:@"%@_%d",key,i];
        NSString *value1 = [NSString stringWithFormat:@"%@_%d",value,i];
        dic[key1] = value1;
    }
    [AnalysysAgent track:@"multiProperties" properties:dic];
    
    [self.view endEditing:YES];
}

- (void)showAlertView:(NSString *)tips {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"tips" message:tips delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}






@end
