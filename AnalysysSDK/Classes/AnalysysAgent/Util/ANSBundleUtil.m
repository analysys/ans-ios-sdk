//
//  ANSBundleUtil.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/3/7.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSBundleUtil.h"

@implementation ANSBundleUtil

+ (id)loadConfigsWithFileName:(NSString *)fileName fileType:(NSString *)type {
    NSString *sourcePath = [self getResourcePathWithFileName:fileName fileType:type];
    NSData *jsonData = [NSData dataWithContentsOfFile:sourcePath];
    if (jsonData == nil) {
        return nil;
    }
    @try {
        NSError *error = nil;
        NSDictionary *configMap = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        if (!error) {
            return configMap;
        }
    } @catch (NSException *exception) {
        
    }
    return nil;
}

/**
 获取资源文件路径
 
 @param fileName 文件名称
 @param type 文件类型
 @return 资源路径
 */
+ (NSString *)getResourcePathWithFileName:(NSString *)fileName fileType:(NSString *)type {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [bundle pathForResource:@"AnalysysAgent" ofType:@"bundle"];
    NSBundle *sourceBundle = [NSBundle bundleWithPath:bundlePath];
    return [sourceBundle pathForResource:fileName ofType:type];
}



@end
