//
//  ANSObjectIdentityProvider.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

/**
 * @class
 * @abstract 对象标识管理
 */

#import <Foundation/Foundation.h>

@interface ANSObjectIdentityProvider : NSObject

/** 获取对象标识 */
- (NSString *)identifierForObject:(id)object;


@end
