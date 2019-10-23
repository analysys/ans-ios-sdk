//
//  ANSFileManager.h
//  AnalysysAgent
//
//  Created by analysys on 2018/3/2.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class
 * ANSFileManager
 *
 * @abstract
 * 文件处理模块
 *
 * @discussion
 * 保存、获取文件信息
 */

@interface ANSFileManager : NSObject

#pragma mark - NSUserDefaults

/**
 本地存储appkey

 @param appKey appkey
 */
+ (void)saveAppKey:(NSString *)appKey;

+ (NSString *)usedAppKey;


/**
 简易数据存储

 @param key key
 @param value value
 */
+ (void)saveUserDefaultWithKey:(NSString *)key value:(id)value;

+ (id)userDefaultValueWithKey:(NSString *)key;

#pragma mark - NSFileManager

/**
 文件默认路径

 @return path
 */
+ (NSString *)defalutDirectoryPath;


/**
 指定路径下文件

 @param fileName 文件名称 如：xxx.plist
 @return 路径
 */
+ (NSString *)filePathWithName:(NSString *)fileName;


/**
 获取本地事件绑定数据

 @return NSSet
 */
+ (NSSet *)unarchiveEventBindings;

/**
 保存事件绑定数据

 @return 存储结果
 */
+ (BOOL)archiveEventBindings:(id)dataInfo;


/**
 序列化常用属性

 @param commonProperties property
 @return yes/no
 */
+ (BOOL)archiveCommonProperties:(NSDictionary*)commonProperties;

/**
 读取本地常用属性
 
 @return property
 */
+ (NSMutableDictionary *)unarchiveCommonProperties;


/**
 序列化超级属性

 @param superProperties property
 @return yes/no
 */
+ (BOOL)archiveSuperProperties:(NSDictionary *)superProperties;

/**
 读取超级属性

 @return property
 */
+ (NSMutableDictionary *)unarchiveSuperProperties;


@end

