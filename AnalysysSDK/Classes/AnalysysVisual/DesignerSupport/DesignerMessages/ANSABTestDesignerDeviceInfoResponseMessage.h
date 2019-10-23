//
//  ANSABTestDesignerDeviceInfoResponseMessage.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSAbstractABTestDesignerMessage.h"
#import <UIKit/UIKit.h>

@interface ANSABTestDesignerDeviceInfoResponseMessage : ANSAbstractABTestDesignerMessage


+ (instancetype)message;

@property (nonatomic, copy) NSString *deviceType;
@property (nonatomic, copy) NSString *systemName;
@property (nonatomic, copy) NSString *systemVersion;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *appBuild;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *deviceModel;
@property (nonatomic, copy) NSString *idfv;
@property (nonatomic, copy) NSString *libVersion;
@property (nonatomic, copy) NSArray *availableFontFamilies;
@property (nonatomic, copy) NSString *mainBundleIdentifier;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;


@end
