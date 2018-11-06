//
//  ViewController.m
//  EGAnalyticsDemo
//
//  Created by analysys on 2018/2/3.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "EGHomeViewController.h"

#import <AnalysysAgent/AnalysysAgent.h>

#import "UIView+MGO.h"

#import "EGTextField.h"


@interface EGHomeViewController ()
@property (weak, nonatomic) IBOutlet EGTextField *textField;
@property (weak, nonatomic) IBOutlet EGTextField *custTF;
@property (weak, nonatomic) IBOutlet EGTextField *keyTextField;
@property (weak, nonatomic) IBOutlet EGTextField *valueTextField;
@property (weak, nonatomic) IBOutlet EGTextField *propertyCountTextField;

@end

@implementation EGHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buyAction:(id)sender {
    
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
        attr[@"PayType"] = @"Alipay";   //  支付方式
        attr[@"Price"] = @160.8;    //  价格
        attr[@"Goods"] = @[@"电脑", @"手机"];   //  商品
        attr[@"HasStock"] = @NO;    //  是否有库存
        attr[@"DeliveryDate"] = [NSDate dateWithTimeIntervalSinceNow:7*24*60*60];;    //  送达日期
        attr[@"Url"] = [NSURL URLWithString:@"http://www.baidu.com"];
        attr[@"Set"] = [NSSet setWithObjects:@"set1",@"set2", nil];
        [AnalysysAgent track:@"Purchase" properties:attr];
    }
    
}

- (IBAction)addEvent:(id)sender {
    if (self.custTF.text.length > 0) {
        [AnalysysAgent track:self.custTF.text properties:@{@"trackTestKey":@[@"trackValue1",@"trackValue2"]}];
    } else {
        [self showAlertView:@"请填写事件名称"];
    }
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
}

- (void)showAlertView:(NSString *)tips {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"tips" message:tips delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}






@end
