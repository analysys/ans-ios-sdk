//
//  ANSFileManager.m
//  AnalysysAgent
//
//  Created by analysys on 2018/3/2.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "ANSFileManager.h"
#import "AnalysysSDK.h"
#import "ANSConsoleLog.h"
#import "NSThread+ANSHelper.h"

@implementation ANSFileManager


#pragma mark - NSUserDefaults

+ (void)saveAppKey:(NSString *)appKey {
    [self saveUserDefaultWithKey:@"AnalysysAppKey" value:appKey];
}

+ (NSString *)usedAppKey {
    return [self userDefaultValueWithKey:@"AnalysysAppKey"];
}

+ (void)saveUserDefaultWithKey:(NSString *)key value:(id)value {
    @try {
        [[AnalysysSDK getUserDefaultLock] lock];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:value forKey:key];
        [defaults synchronize];
        [[AnalysysSDK getUserDefaultLock] unlock];
    } @catch (NSException *exception) {
        
    }
}

+ (id)userDefaultValueWithKey:(NSString *)key {
    [[AnalysysSDK getUserDefaultLock] lock];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id retVaule = [[defaults valueForKey:key] copy];
    [[AnalysysSDK getUserDefaultLock] unlock];
    return retVaule;
}

#pragma mark - NSFileManager

/** 文件路径 */
+ (NSString *)defalutDirectoryPath {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

/** 拼接路径 */
+ (NSString *)filePathWithName:(NSString *)fileName {
    NSString *filename = [NSString stringWithFormat:@"/SYSYLANA/%@",fileName];
    NSString *filePath = [[ANSFileManager defalutDirectoryPath] stringByAppendingPathComponent:filename];
    NSURL *URL = [NSURL fileURLWithPath:filePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isPathExists = [fileManager fileExistsAtPath:[URL path]];
    if (!isPathExists) {
        [self createFileAtPath:filePath];
    }
    return filePath;
}

/** 读取本地存储属性 */
+ (NSMutableDictionary *)unarchiveCommonProperties {
    NSString *filePath = [self filePathWithName:@"commonProperties.plist"];
    return [self unarchiveDataAtFilePath:filePath asClass:[NSDictionary class]] ?: [NSMutableDictionary dictionary];
}

/** 写入属性 */
+ (BOOL)archiveCommonProperties:(NSDictionary*)commonProperties {
    NSString *filePath = [self filePathWithName:@"commonProperties.plist"];
    return [ANSFileManager archiveObject:commonProperties withFilePath:filePath];
}

/** 读取通用属性 */
+ (NSMutableDictionary *)unarchiveSuperProperties {
    NSString *filePath = [self filePathWithName:@"superProperties.plist"];
    return [self unarchiveDataAtFilePath:filePath asClass:[NSDictionary class]] ?: [NSMutableDictionary dictionary];
}

/** 写入通用属性 */
+ (BOOL)archiveSuperProperties:(NSDictionary *)superProperties {
    NSString *filePath = [self filePathWithName:@"superProperties.plist"];
    return [ANSFileManager archiveObject:superProperties withFilePath:filePath];
}

/** 读取本地事件绑定数据 */
+ (NSSet *)unarchiveEventBindings {
    NSString *filePath = [self filePathWithName:@"eventBindings.plist"];
    return [self unarchiveDataAtFilePath:filePath asClass:[NSSet class]] ?: [NSSet set];
}

/** 保存事件绑定数据 */
+ (BOOL)archiveEventBindings:(id)dataInfo {
    NSString *filePath = [self filePathWithName:@"eventBindings.plist"];
    return [ANSFileManager archiveObject:dataInfo withFilePath:filePath];
}

#pragma mark - inner

/** 创建目录 */
+ (void)createFileAtPath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSRange range = [filePath rangeOfString:@"/" options:NSBackwardsSearch];
    NSString *directryPath = [filePath substringToIndex:range.location];
    NSError *error = nil;
    [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!error) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    } else {
        AnsDebug(@"Directory create failure！");
    }
}

+ (BOOL)archiveObject:(id)object withFilePath:(NSString *)filePath {
    @try {
        if (![NSKeyedArchiver archiveRootObject:object toFile:filePath]) {
            return NO;
        }
    } @catch (NSException* exception) {
        AnsError(@"Data archive error: %@!", exception);
        return NO;
    }
    
    return YES;
}

+ (id)unarchiveDataAtFilePath:(NSString *)filePath asClass:(Class)class {
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    if (data.length == 0) {
        return nil;
    }
    
    id unarchivedData = nil;
    @try {
        unarchivedData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (![unarchivedData isKindOfClass:class]) {
            unarchivedData = nil;
        }
    } @catch (NSException *exception) {
        NSError *error = NULL;
        BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (!removed) {
            AnsDebug(@"File removed failure: %@", error);
        }
    }
    return unarchivedData;
}

@end

