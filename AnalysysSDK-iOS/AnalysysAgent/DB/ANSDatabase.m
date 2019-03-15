//
//  ANSDatabase.m
//  AnalysysAgent
//
//  Created by analysys on 2018/2/9.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "ANSDatabase.h"
#import <sqlite3.h>

#import "ANSJsonUtil.h"
#import "ANSConsleLog.h"
#import "AnalysysAgent.h"
#import "ANSFileManager.h"

//  数据存储表
static NSString *const AnsDataTable = @"record_data";
static NSString *const AnsDataTableSql = @"\
        create table if not exists record_data (\
        id integer primary key autoincrement,\
        type text,\
        json_string text,\
        create_date text,\
        column1 text,\
        column2 text\
    );";

@interface ANSDatabase ()

@property (nonatomic) sqlite3 *database;

@end

@implementation ANSDatabase {
    dispatch_queue_t _sqliteQueue;
    NSInteger _dataCount;
    ANSJsonUtil *_jsonUtil;
    NSDateFormatter *_dateFormatter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dataCount = 0;
        _jsonUtil = [[ANSJsonUtil alloc] init];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        NSString *label = [NSString stringWithFormat:@"com.analysys.sqliteQueue"];
        _sqliteQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
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

#pragma mark *** interface ***

/** 创建数据库 */
- (id)initWithDatabaseName:(NSString *)databaseName {
    self = [self init];
    if (self) {
        NSString *dbPath = [ANSFileManager filePathWithName:databaseName];
        AnsDebug(@"Database path：%@",dbPath);

        [self createDatabaseWithPath:dbPath];
        
        [self createTables];
    }
    return self;
}

//  默认清理数据条数
static NSInteger const defaultDelRecords = 10;
/** 插入采集数据 */
- (BOOL)insertRecordObject:(id)object type:(NSUInteger)type {
    @try {
        NSString *jsonString = nil;
        NSInteger maxCacheSize = [AnalysysAgent maxCacheSize];
        if (_dataCount > maxCacheSize) {
            AnsWarning(@"The number of data storage exceeds the maximum value: %ld, will clean up 10 old data!",(long)maxCacheSize);
            [self deleteTopRecords:defaultDelRecords type:@""];
        }
        NSData *jsonData = [_jsonUtil jsonSerializeWithObject:object];
        if (!jsonData) {
            AnsWarning(@"Insert json data is nil!");
            return NO;
        }
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *sql = [NSString stringWithFormat:@"insert into %@ (type, json_string, create_date) values('%@', '%@', '%@');", AnsDataTable, [NSString stringWithFormat:@"%lu",(unsigned long)type], jsonString, [self->_dateFormatter stringFromDate:[NSDate date]]];
        if ([self execSql:sql]) {
            self->_dataCount++;
            return YES;
        }
    } @catch (NSException *exception) {
        AnsError(@"Database: insert data exception :%@", exception);
        return NO;
    }
}

/** 删除指定类型top数据 */
- (BOOL)deleteTopRecords:(NSInteger)limit type:(NSString *)type {
    NSString *where = @"";
    if (type.length > 0) {
        where = [NSString stringWithFormat:@" where type = '%@'", type];
    }
    NSString *limitStr = @"";
    if (limit != 0) {
        limitStr = [NSString stringWithFormat:@"limit %ld ",(long)limit];
    }
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where id in (select id from %@ %@ order by id asc %@);", AnsDataTable, AnsDataTable, where, limitStr];
    BOOL result = NO;
    result = [self execSql:sql];
    if (result) {
        if (limit == 0) {
            self->_dataCount = 0;
        } else {
            NSInteger count = self->_dataCount - limit;
            self->_dataCount = count <=0 ? 0 : count;
        }
    }
    return result;
}

/** 获取指定类型top数据 */
- (NSArray *)getTopRecords:(NSInteger)limit type:(NSString *)type {
    NSArray *records = [NSArray array];
    if (_dataCount == 0) {
        return records;
    }
    @try {
        NSString *where = @"";
        NSString *limitStr = @"";
        NSString *selelctSQL ;
        if (type.length > 0) {
            where = [NSString stringWithFormat:@"where type = '%@'", type];
        }
        if (limit) {
            limitStr = [NSString stringWithFormat:@"limit %ld", (long)limit];
        }
        selelctSQL = [NSString stringWithFormat:@"select json_string from %@ %@ order by id asc %@", AnsDataTable, where, limitStr];
        
        records = [self selectDataWithSQL:selelctSQL];
    } @catch (NSException *exception) {
        AnsError(@"Database get data exception: %@", exception);
    }
    return records;
}

/** 获取表条数 */
- (NSInteger)recordRows {
    return _dataCount;
}

#pragma mark *** private ***

/** 获取数据库数据使用同步队列获取，防止数据库锁死 */
- (void)operateSqlite:(void(^)(sqlite3 *db))handler {
    dispatch_sync(_sqliteQueue, ^{
        if (self.database) {
            handler(self.database);
        } else {
            AnsDebug(@"数据库创建失败!");
        }
    });
}

/** 根据路径创建数据库 */
- (void)createDatabaseWithPath:(NSString *)path {
    if (sqlite3_initialize() != SQLITE_OK) {
        AnsError(@"Database init failure!");
    }
    //  SQLITE_OPEN_FULLMUTEX  多线程操作数据库保证线程安全
    if (sqlite3_open_v2([path UTF8String], &_database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, NULL) == SQLITE_OK) {
        AnsDebug(@"Database create success.");
    } else {
        [self closeDatabase];
        AnsError(@"Database create failure: %s",sqlite3_errmsg(_database));
    }
}

/** 创建默认数据库表 */
- (void)createTables {
    @try {
        if ([self execSql:AnsDataTableSql]) {
            self->_dataCount = [self rowCountOfTable:AnsDataTable];
        }
    } @catch (NSException *exception) {
        AnsError(@"Data create table exception: %@", exception);
    }
}

/** 查询数据库数据 */
- (NSArray *)selectDataWithSQL:(NSString *)sql {
    NSMutableArray *dataArray = [NSMutableArray array];
    @try {
        [self operateSqlite:^(sqlite3 *db) {
            sqlite3_stmt* stmt = NULL;
            int sqlResult = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL);
            if(sqlResult == SQLITE_OK) {
                while (sqlite3_step(stmt) == SQLITE_ROW) {
                    char *text = (char*)sqlite3_column_text(stmt, 0);
                    NSString *textStr = [NSString stringWithUTF8String:text];
                    [dataArray addObject:textStr];
                }
            } else {
                AnsError(@"Database SQL prepare failure:%s!", sqlite3_errmsg(db));
                sqlite3_finalize(stmt);
            }
        }];
    } @catch (NSException *exception) {
        AnsError(@"Database SQL excute exception:%@!", exception);
    }
    return [NSArray arrayWithArray:dataArray];
}

/** 表 记录 条数 */
- (NSInteger)rowCountOfTable:(NSString *)tableName {
    @try {
        NSString *query = [NSString stringWithFormat:@"select count(*) from %@;", tableName];
        sqlite3_stmt* statement = NULL;
        NSInteger count = -1;
        int rc = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, NULL);
        if(rc == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                count = sqlite3_column_int(statement, 0);
            }
        } else {
            AnsError(@"Database SQL prepare failure:%d %s!", rc, sqlite3_errmsg(_database));
            sqlite3_finalize(statement);
        }
        return count;
    } @catch (NSException *exception) {
        AnsError(@"Database SQL excute exception:%@!", exception);
    }
    return 0;
}

/** 执行sql */
- (BOOL)execSql:(NSString *)sql {
    __block BOOL result = NO;
    @try {
        [self operateSqlite:^(sqlite3 *db) {
            sqlite3_stmt* statement = NULL;
            int insertResult = sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL);
            if (insertResult == SQLITE_OK) {
                sqlite3_step(statement);
                result = YES;
            } else {
                AnsError(@"Database SQL prepare failure:%d %s!", result, sqlite3_errmsg(db));
                sqlite3_finalize(statement);
            }
        }];
    } @catch (NSException *exception) {
        AnsError(@"Database SQL excute exception:%@!", exception);
    }
    return result;
}


@end
