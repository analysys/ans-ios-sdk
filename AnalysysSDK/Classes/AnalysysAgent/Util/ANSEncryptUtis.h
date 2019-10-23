//
//  ANSEncryptUtis.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/10/16.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ANSEncryptUtis : NSObject

/**
 http上传头信息
 
 @return dic
 */
+ (NSDictionary *)httpHeaderInfo;

/**
 获取上传数据
 
 @param bodyJson 上传json
 @param param 参数
 @return http body
 */
+ (NSString *)processUploadBody:(NSString *)bodyJson param:(NSDictionary *)param;


@end

NS_ASSUME_NONNULL_END
