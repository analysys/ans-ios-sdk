//
//  ANSObjectSerializer.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

/** 对图层控件对象序列格式化 */

#import <Foundation/Foundation.h>

@class ANSClassDescription;
@class ANSObjectSerializerContext;
@class ANSObjectSerializerConfig;
@class ANSObjectIdentityProvider;

@interface ANSObjectSerializer : NSObject


/*!
 An array of ANSClassDescription instances.
 */
- (instancetype)initWithConfiguration:(ANSObjectSerializerConfig *)configuration objectIdentityProvider:(ANSObjectIdentityProvider *)objectIdentityProvider;


/**
 将当前 rootObject 对象下所有子对象组成上传信息

 @param rootObject 对象
 @return 上传结构信息
 */
- (NSDictionary *)serializedObjectsWithRootObject:(id)rootObject;


@end
