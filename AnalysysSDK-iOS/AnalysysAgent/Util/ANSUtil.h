//
//  ANSUtil.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/23.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class
 * ANSUtils
 *
 * @abstract
 * 工具类
 *
 * @discussion
 * 基本工具方法
 */


@interface ANSUtil : NSObject

/**
 当前时间戳/毫秒
 
 @return 时间戳
 */
+ (long long)currentTimeMillisecond;

/**
 当前根视图
 
 @return rootVC
 */
+ (UIViewController *)rootViewController;

/**
 当前栈顶controller
 
 @return controller
 */
+ (UIViewController *)topViewController;

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
