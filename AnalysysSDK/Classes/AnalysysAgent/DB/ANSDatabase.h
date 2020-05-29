//
//  ANSDatabase.h
//  AnalysysAgent
//
//  Created by analysys on 2018/2/9.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class
 * ANSDatabase
 *
 * @abstract
 * 封装sqlite操作
 *
 * @discussion
 * 二次封装sqlite操作
 */

@interface ANSDatabase : NSObject


/**
 创建数据库

 @param databaseName 数据库名称
 @return helper对象
 */
- (id)initWithDatabaseName:(NSString *)databaseName;


/**
 插入采集数据

 @param object 采集结果对象
 @param event 事件标识
 @param maxCacheSize 最大缓存条数
 */
- (void)insertRecordObject:(id)object event:(NSString *)event maxCacheSize:(NSInteger)maxCacheSize result:(void(^)(BOOL success))result;

/**
 删除已上传数据
 
 @param type 类型过滤条件
 @return 是否删除成功
 */
- (BOOL)deleteUploadRecordsWithType:(NSString *)type;

/** 清理数据库 */
- (void)cleanDBCache;

/** 上传失败后重置数据状态 */
- (void)resetUploadRecordsWithType:(NSString *)type;

/**
 数据表条数

 @return 数据条数
 */
- (NSInteger)recordRows;

/// 重置数据标识
/// 用于：1.数据上传 2. 时间校准
- (void)resetLogStatus;


/**
 获取指定类型top:时间由老到新
 获取指定类型last:时间由新到老

 @param limit 条数
 @param type 类型过滤条件，若为空则不区分类型
 */
- (void)getTopRecords:(NSInteger)limit type:(NSString *)type result:(void(^)(BOOL success, NSArray *resultArray))result;

- (void)getLastRecords:(NSInteger)limit type:(NSString *)type result:(void(^)(BOOL success, NSArray *resultArray))result;





@end
