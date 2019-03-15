//
//  ANSModuleConfig.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/3/7.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class
 * ANSModuleConfig
 *
 * @abstract
 * 模块配置
 *
 * @discussion
 * 每个模块中使用的配置信息
 */

@interface ANSModuleConfig : NSObject

/**
 模块配置

 @return 配置信息
 */
+ (NSDictionary *)allModuleConfig;

@end


