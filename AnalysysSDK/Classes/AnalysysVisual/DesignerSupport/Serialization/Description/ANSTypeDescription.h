//
//  ANSTypeDescription.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

/**
 * @class
 * @abstract 服务器配置信息基类
 */

#import <Foundation/Foundation.h>

@interface ANSTypeDescription : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/** 类或枚举名称 */
@property (nonatomic, readonly) NSString *name;


@end
