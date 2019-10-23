//
//  ANSABTestDesignerSnapshotRequestMessage.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSAbstractABTestDesignerMessage.h"

@class ANSObjectSerializerConfig;

extern NSString *const ANSDesignerSnapshotRequestMessageType;


@interface ANSABTestDesignerSnapshotRequestMessage : ANSAbstractABTestDesignerMessage


+ (instancetype)message;

@property (nonatomic, readonly) ANSObjectSerializerConfig *configuration;


@end
