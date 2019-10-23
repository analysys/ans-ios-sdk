//
//  ANSDataEncrypt.h
//  AnalysysAgent
//
//  Created by SoDo on 2018/9/10.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class
 * ANSDataEncrypt
 *
 * @abstract
 * 数据加密
 *
 * @discussion
 * 对上传数据加密操作
 */

@interface ANSDataEncrypt : NSObject

/**
 header额外信息

 @return map
 */
+ (NSDictionary *)extroHeaderInfo;

/**
 加密上传数据

 @param jsonString 原始上传数据
 @return 加密后数据
 */
+ (NSString *)encryptJsonString:(NSString *)jsonString param:(NSDictionary *)param;


@end
