//
//  NSInvocation+ANSHelper.h
//  AnalysysAgent
//
//  Created by analysys on 2019/2/21.
//  Copyright © 2019年 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (ANSHelper)

/**
 设置参数

 @param argumentArray 参数列表
 */
- (void)AnsSetArgumentsFromArray:(NSArray *)argumentArray;

/**
 返回值

 @return object
 */
- (id)AnsReturnValue;

@end
