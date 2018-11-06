//
//  ThirdViewController.h
//  EGAnalyticsDemo
//
//  Created by analysys on 2018/2/3.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "EGBaseViewController.h"

@interface NextViewController : EGBaseViewController

//  为方便测试，若接口已设置忽略该页面自动采集功能，则开发者可在 viewWillAppear: 中手动调用 pageView: 或 pageView:properties: 方法
@property (nonatomic, assign) BOOL ignoredAutoCollection;

@end
