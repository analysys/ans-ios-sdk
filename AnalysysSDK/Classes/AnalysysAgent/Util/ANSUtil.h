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
+ (long long)nowTimeMilliseconds;

/// 检测http请求地址合法性，并返回合适字符串
/// @param urlString 源地址
+ (NSString *)getHttpUrlString:(NSString *)urlString;

/// 检测websocket地址合法性，并返回合适字符串
/// @param urlString 源地址
+ (NSString *)getSocketUrlString:(NSString *)urlString;

/**
 对字符串进行字节截取

 @param string 字符串
 @param length 字节数
 @return 新字符串
 */
+ (NSString *)subByteString:(NSString *)string byteLength:(NSInteger )length;


/// 获取当前使用的window对象
/// 适配xcode11使用SceneDelegate对象创建window
+ (UIWindow *)currentKeyWindow;


+ (NSArray *)allPropertiesWithObject:(Class)objectCls;

@end

NS_ASSUME_NONNULL_END
