//
//  ANSEnumDescription.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.


/**
 * 服务器下发配置中的 枚举 对象
 */

#import "ANSTypeDescription.h"

@interface ANSEnumDescription : ANSTypeDescription


@property (nonatomic, assign, getter=isFlagsSet, readonly) BOOL flagSet;
@property (nonatomic, copy, readonly) NSString *baseType;

- (NSArray *)allValues; // array of NSNumber instances


@end
