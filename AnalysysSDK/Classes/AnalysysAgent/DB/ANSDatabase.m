//
//  ANSDatabase.m
//  AnalysysAgent
//
//  Created by analysys on 2018/2/9.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "ANSDatabase.h"
#import <sqlite3.h>

#import "AnalysysLogger.h"
#import "ANSFileManager.h"
#import "ANSJsonUtil.h"
#import "NSString+ANSDBEncrypt.h"
#import "ANSDateUtil.h"
#import "AnalysysAgentConfig.h"
#import "ANSConst+private.h"

/**
数据排序

- AnalysysOrderAsc: 升序
- AnalysysOrderDesc: 降序
*/
typedef NS_ENUM(NSInteger, AnalysysOrder) {
    AnalysysOrderAsc = 0,
    AnalysysOrderDesc = 1
};

/// 数据缓存对象
@interface ANSStatement : NSObject

/** sql */
@property (nonatomic, copy) NSString *sql;

/** SQLite sqlite3_stmt */
@property (atomic, assign) void *statement;

@end

@implementation ANSStatement

@end

//  以下两个参数4.3.5之后每次冷启动置为null
//  column1：数据上传状态。默认：空(null)；1：数据正在上传
//  column2：数据是否为本地启动采集。历史数据：默认空(null)；4.3.5之后数据插入即为1(用于时间校准)

@interface ANSDatabase ()

@property (nonatomic) sqlite3 *database;

@end

@implementation ANSDatabase {
    dispatch_queue_t _sqliteQueue;
    NSInteger _dataCount;
    NSMutableDictionary *_stmtMap;
    NSMutableArray *_ids;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dataCount = 0;
        _ids = [NSMutableArray array];
        _stmtMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    [self closeDatabase];
}

/** 关闭数据库连接 */
- (void)closeDatabase {
    sqlite3_close(_database);
    sqlite3_shutdown();
}

#pragma mark - interface

/** 创建数据库 */
- (id)initWithDatabaseName:(NSString *)databaseName {
    self = [self init];
    if (self) {
        NSString *dbPath = [ANSFileManager filePathWithName:databaseName];
        ANSDebug(@"Database path：%@",dbPath);
        
        if (sqlite3_initialize() != SQLITE_OK) {
            ANSDebug(@"Database init failure!");
            return nil;
        }
        //  SQLITE_OPEN_FULLMUTEX  多线程操作数据库保证线程安全
        if (sqlite3_open_v2([dbPath UTF8String], &_database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, NULL) != SQLITE_OK) {
            [self closeDatabase];
            ANSDebug(@"Database create failure: %s",sqlite3_errmsg(_database));
            return nil;
        }

        NSString *tableSQL = @"create table if not exists record_data (id integer primary key autoincrement, type text, json_string text, create_date text, column1 text,column2 text);";
        char *error;
        if (sqlite3_exec(_database, [tableSQL UTF8String], NULL, NULL, &error) != SQLITE_OK) {
            ANSDebug(@"Database create failure: %s",sqlite3_errmsg(_database));
            return nil;
        }
        
        [self vacuumDatabase];
        _dataCount = [self tableRows];
    }
    return self;
}

/** 插入采集数据 */
- (void)insertRecordObject:(id)object event:(NSString *)event maxCacheSize:(NSInteger)maxCacheSize result:(void (^)(BOOL))result {
    if (!result) {
        return;
    }
    @try {
        NSString *jsonString = nil;
        if (_dataCount > maxCacheSize) {
            ANSBriefWarning(@"The number of data storage exceeds the maximum value: %ld, will clean up 10 old data!",(long)maxCacheSize);
            [self deleteTopRecords];
        }
        NSData *jsonData = [ANSJsonUtil jsonSerializeWithObject:object];
        if (!jsonData) {
            ANSBriefWarning(@"Insert json data is nil!");
            result(NO);
            return;
        }
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *query = @"insert into record_data (type, json_string, create_date, column2) values(?, ?, ?, 1)";
        sqlite3_stmt *pStmt = [self cachedStatementForQuery:query];
        if (pStmt) {
            NSString *dateStr = [[ANSDateUtil dateFormat] stringFromDate:[NSDate date]];
            NSString *base64String = [jsonString ansBase64Encode];
            NSArray *params = @[event, base64String, dateStr];
            if ([self execStatement:pStmt paramArray:params]) {
                _dataCount++;
//                ANSLog(@"Data insert success!!\n %@",object);
                result(YES);
                return;
            } else {
                result(NO);
                return;
            }
        } else {
            result(NO);
            return;
        }
    } @catch (NSException *exception) {
        ANSBriefError(@"Database: insert data exception :%@", exception);
        result(NO);
        return;
    }
}

- (void)cleanDBCache {
    NSString *query = @"delete from record_data";
    sqlite3_stmt *pStmt = [self cachedStatementForQuery:query];
    if ([self execStatement:pStmt paramArray:nil]) {
        _dataCount = 0;
    }
}

- (void)resetUploadRecordsWithType:(NSString *)type {
    NSString *where = @"";
    if (type.length > 0) {
        where = [NSString stringWithFormat:@"where type = '%@' and column1='1' ", type];
    } else {
        where = @"where column1='1'";
    }
    
    NSString *query = [NSString stringWithFormat:@"update record_data set column1=null %@ ", where];
    sqlite3_stmt *pStmt = [self cachedStatementForQuery:query];
    if ([self execStatement:pStmt paramArray:nil]) {
        
    }
}

/** 删除指定类型top数据 */
- (BOOL)deleteUploadRecordsWithType:(NSString *)type {
    NSString *where = @"";
    if (type.length > 0) {
        where = [NSString stringWithFormat:@"where type = '%@' and column1='1' ", type];
    } else {
        where = @"where column1='1'";
    }
    
    NSString *query = [NSString stringWithFormat:@"delete from record_data %@", where];
    sqlite3_stmt *pStmt = [self cachedStatementForQuery:query];
    if ([self execStatement:pStmt paramArray:nil]) {
        _dataCount -= _ids.count;
        if (_dataCount < 0) {
            _dataCount = [self tableRows];
        }
        return YES;
    }
    return NO;
}

- (void)getTopRecords:(NSInteger)limit type:(NSString *)type result:(void (^)(BOOL, NSArray *))result {
    [self getTopRecords:limit type:type orderBy:AnalysysOrderAsc result:^(BOOL success, NSArray *resultArray) {
        result(success, resultArray);
    }];
}

- (void)getLastRecords:(NSInteger)limit type:(NSString *)type result:(void (^)(BOOL, NSArray *))result{
    [self getTopRecords:limit type:type orderBy:AnalysysOrderDesc result:^(BOOL success, NSArray *resultArray) {
        result(success, resultArray);
    }];
}

/** 获取指定类型top数据 */
- (void)getTopRecords:(NSInteger)limit type:(NSString *)type orderBy:(AnalysysOrder)orderBy result:(void (^)(BOOL success, NSArray *resultArray))result {
    if (!result) {
        return;
    }
    NSMutableArray *records = [NSMutableArray array];
    if (_dataCount <= 0) {
        if (_dataCount < 0) {
            _dataCount = [self tableRows];
        }
        result(NO,records);
        return;
    }
    @try {
        NSString *where = @"";
        NSString *limitStr = @"";
        NSString *selelctSQL;
        if (type.length > 0) {
            where = [NSString stringWithFormat:@"where type = '%@'", type];
        }
        if (limit) {
            limitStr = [NSString stringWithFormat:@"limit %ld", (long)limit];
        }
        selelctSQL = [NSString stringWithFormat:@"select id, json_string, column2 from record_data %@ order by id %@ %@", where, orderBy == AnalysysOrderAsc ? @"asc": @"desc", limitStr];
        
        [_ids removeAllObjects];
        sqlite3_stmt *pStmt = [self cachedStatementForQuery:selelctSQL];
        if (pStmt) {
            while (sqlite3_step(pStmt) == SQLITE_ROW) {
                NSMutableDictionary *logInfo = [NSMutableDictionary dictionary];
                
                NSInteger index = sqlite3_column_int(pStmt, 0);
                [_ids addObject:[NSString stringWithFormat:@"%ld", (long)index]];
                
                char *logText = (char*)sqlite3_column_text(pStmt, 1);
                NSString *logString = [NSString stringWithUTF8String:logText];
                NSString *logJsonString = [logString ansBase64Decode];
                if (logJsonString.length == 0) {
                    logJsonString = logString;
                }
                if ([self validOfJsonString:logJsonString]) {
                    logInfo[ANSLogJson] = logJsonString;
                }
                
                char *oldOrNew = (char*)sqlite3_column_text(pStmt, 2);
                if (oldOrNew) {
                    NSString *oldOrNewString = [NSString stringWithUTF8String:oldOrNew];
                    logInfo[ANSLogOldOrNew] = oldOrNewString;
                }
                
                [records addObject:logInfo];
            }
        }
    }
    @catch (NSException *exception) {
            ANSBriefError(@"Database get data exception: %@", exception);
    }
        
    [self markUploadData];
    
    result(YES, records);
}

/** 获取表条数 */
- (NSInteger)recordRows {
    return _dataCount;
}

- (void)resetLogStatus {
    NSString *query = [NSString stringWithFormat:@"update record_data set column1 = null, column2 = null"];
    sqlite3_stmt *pStmt = [self cachedStatementForQuery:query];
    if ([self execStatement:pStmt paramArray:nil]) {
        ANSDebug(@"reset data success");
    } else {
        ANSDebug(@"reset data failed");
    }
}

#pragma mark - private

- (void)vacuumDatabase {
    @try {
        NSString *query = @"VACUUM";
        char *errMsg;
        if (sqlite3_exec(_database, [query UTF8String], NULL, NULL, &errMsg) != SQLITE_OK) {
            ANSDebug(@"Failed to vacuum. error:%s", errMsg);
        }
    } @catch (NSException *exception) {

    }
}

/** 表 记录 条数 */
- (NSInteger)tableRows {
    @try {
        NSString *query = [NSString stringWithFormat:@"select count(*) from record_data"];
        sqlite3_stmt *pStmt = [self cachedStatementForQuery:query];
        NSInteger count = 0;
        if (pStmt) {
            while (sqlite3_step(pStmt) == SQLITE_ROW) {
                count = sqlite3_column_int(pStmt, 0);
            }
        }
        return count;
    } @catch (NSException *exception) {
        ANSDebug(@"Database SQL excute exception:%@!", exception);
    }
    return 0;
}

/** 执行sql */
- (BOOL)execStatement:(sqlite3_stmt *)statement paramArray:(NSArray *)paramArray {
    @try {
        for (int i = 0; i < paramArray.count; i++) {
            NSString *value = paramArray[i];
            sqlite3_bind_text(statement, i+1, [value UTF8String], -1, SQLITE_STATIC);
        }
        if (sqlite3_step(statement) == SQLITE_DONE) {
            return YES;
        }
        
        ANSBriefError(@"Database SQL prepare failure: %s!", sqlite3_errmsg(_database));
        sqlite3_finalize(statement);
        [self removeCachedStatement:statement];
    } @catch (NSException *exception) {
        ANSBriefError(@"Database SQL excute exception:%@!", exception);
    }
    return NO;
}

/** 缓存sqlite3_stmt */
- (sqlite3_stmt *)cachedStatementForQuery:(NSString *)sql {
    if (sql.length == 0 || !_stmtMap) return NULL;
    ANSStatement *statement = [_stmtMap objectForKey:sql];
    sqlite3_stmt *stmt = statement.statement;
    if (!stmt) {
        int result = sqlite3_prepare_v2(_database, sql.UTF8String, -1, &stmt, NULL);
        if (result != SQLITE_OK) {
            ANSBriefError(@"Sqlite stmt prepare error (%d): %s", result, sqlite3_errmsg(_database));
            return NULL;
        }
        ANSStatement *statement = [[ANSStatement alloc] init];
        statement.sql = sql;
        statement.statement = stmt;
        [_stmtMap setValue:statement forKey:sql];
    } else {
        sqlite3_reset(stmt);
    }
    return stmt;
}

/** 删除缓存sqlite3_stmt */
- (void)removeCachedStatement:(sqlite3_stmt *)statement {
    NSString *tempKey = @"";
    for (id key in _stmtMap) {
        ANSStatement *value = _stmtMap[key];
        if (value.statement == statement) {
            tempKey = key;
        }
    }
    [self->_stmtMap removeObjectForKey:tempKey];
}

/** 标记正在上传数据 */
- (void)markUploadData {
    NSMutableArray *paramArray = [NSMutableArray array];
    if (_ids.firstObject == nil || _ids.lastObject == nil) {
        return;
    }
    [paramArray addObject:_ids.firstObject];
    [paramArray addObject:_ids.lastObject];

    NSString *query = [NSString stringWithFormat:@"update record_data set column1='1' where id >= ? and id <= ?"];
    sqlite3_stmt *pStmt = [self cachedStatementForQuery:query];
    if (![self execStatement:pStmt paramArray:paramArray]) {
        ANSDebug(@"Sqlite update failed");
    }
}

//  默认清理数据条数
- (void)deleteTopRecords {
    NSString *query = @"delete from record_data where id in (select id from record_data order by id asc limit 10)";
    sqlite3_stmt *pStmt = [self cachedStatementForQuery:query];
    if ([self execStatement:pStmt paramArray:nil]) {
        ANSDebug(@"清理成功");
        _dataCount = (_dataCount - 10 > 0) ? (_dataCount - 10) : 0;
    }
}

/** 基础字段校验 */
- (BOOL)validOfJsonString:(NSString *)json {
    NSDictionary *dataMap = [ANSJsonUtil convertToMapWithString:json];
    if (![dataMap.allKeys containsObject:ANSAppid] ||
        ![dataMap.allKeys containsObject:ANSXwho] ||
        ![dataMap.allKeys containsObject:ANSXwhat] ||
        ![dataMap.allKeys containsObject:ANSXwhen] ||
        ![dataMap.allKeys containsObject:ANSXcontext]) {
        return NO;
    }
    NSString *appKey = dataMap[ANSAppid];
    if (![appKey isEqualToString:AnalysysConfig.appKey]) {
        return NO;
    }
    return YES;
}



@end
