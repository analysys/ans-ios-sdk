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
 @param type 数据类型字段
 @return 是否成功
 */
- (BOOL)insertRecordObject:(id)object type:(NSUInteger)type;

/**
 删除指定类型top数据
 
 @param limit 条数
 @param type 类型过滤条件
 @return 是否删除成功
 */
- (BOOL)deleteTopRecords:(NSInteger)limit type:(NSString *)type;


/**
 数据表条数

 @return 数据条数
 */
- (NSInteger)recordRows;


/**
 获取指定类型top数据

 @param limit 条数
 @param type 类型过滤条件，若为空则不区分类型
 @return 返回json数组
 */
- (NSArray *)getTopRecords:(NSInteger)limit type:(NSString *)type;





@end
