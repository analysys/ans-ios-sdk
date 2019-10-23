//
//  ANSABTestDesignerSnapshotResponseMessage.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSAbstractABTestDesignerMessage.h"

#import <UIKit/UIKit.h>

@interface ANSABTestDesignerSnapshotResponseMessage : ANSAbstractABTestDesignerMessage


+ (instancetype)message;

@property (nonatomic, strong) UIImage *screenshot;
@property (nonatomic, copy) NSDictionary *serializedObjects;
@property (nonatomic, strong, readonly) NSString *imageHash;
@property (nonatomic, copy) NSString *msgCode;


/// 添加额外响应信息
- (void)addExtroResponseInfo;


@end
