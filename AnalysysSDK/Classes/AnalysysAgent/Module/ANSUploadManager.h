//
//  ANSUploadManager.h
//  AnalysysAgent
//
//  Created by analysys on 2018/3/1.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SuccessBlock)(NSURLResponse *response, NSData *responseData);
typedef void(^FailureBlock)(NSError *error);

/**
 * @class
 * ANSUploadManager
 *
 * @abstract
 * 上传模块
 *
 * @discussion
 * 处理数据上传
 */

@interface ANSUploadManager : NSObject


/**
 post请求

 @param URLStr 服务器地址
 @param header 请求头信息
 @param body 请求body体
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
- (void)postRequestWithServerURLStr:(NSString *)URLStr
                             header:(NSDictionary *)header
                               body:(id)body
                            success:(SuccessBlock)successBlock
                            failure:(FailureBlock)failureBlock;

/**
 get请求

 @param URLStr 服务器地址
 @param parameters 参数信息
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
- (void)getRequestWithServerURLStr:(NSString *)URLStr
                        parameters:(NSDictionary *)parameters
                           success:(SuccessBlock)successBlock
                           failure:(FailureBlock)failureBlock;



@end
