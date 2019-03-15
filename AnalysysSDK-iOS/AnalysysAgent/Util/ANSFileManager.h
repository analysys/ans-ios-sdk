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


+ (instancetype)sharedManager;

// 自定义常用属性
@property (nonatomic, strong) NSMutableDictionary *normalProperties;
// 用户通用属性
@property (nonatomic, strong) NSMutableDictionary *globalProperties;


#pragma mark *** NSUserDefaults ***

/**
 本地存储appkey
 
 @param appKey appkey
 */
+ (void)saveAppKey:(NSString *)appKey;

+ (NSString *)usedAppKey;

#pragma mark *** NSFileManager ***

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
 存入本地常用属性
 */
+ (BOOL)saveNormalProperties;

/**
 写入本地通用属性信息
 */
+ (BOOL)saveGlobalProperties;


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



@end
