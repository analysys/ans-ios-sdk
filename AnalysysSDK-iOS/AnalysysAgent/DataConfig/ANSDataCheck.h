//
//  ANSDataCheck.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class
 * ANSDataCheck
 *
 * @abstract
 * 对数据配置中带有校验规则的数据进行校验
 *
 * @discussion
 * 该类中的方法名称必须与规则配置文件 checkFuncList 中一一对应
 * 如：ANSDataCheck.isValidOfIncrementValue
 */


@interface ANSDataCheck : NSObject

@end

