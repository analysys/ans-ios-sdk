//
//  AnalysysLogData.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/27.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "AnalysysLogData.h"
@interface AnalysysLogData()

@end

@implementation AnalysysLogData

+ (instancetype)sharedSingleton {
    static AnalysysLogData *_dataSingleTon = nil;
    static dispatch_once_t onceTask;
    dispatch_once(&onceTask, ^{
        _dataSingleTon = [[AnalysysLogData alloc] init];
    });
    return _dataSingleTon;
}

- (NSMutableArray *)logData {
    if (!_logData) {
        _logData = [NSMutableArray array];
    }
    return _logData;
}

// 获取当前时间
+ (NSString *)getCurrentDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; // 创建一个时间格式化对象
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SS"]; // 设定时间格式,这里可以设置成自己需要的格式
    NSString *dateString = [dateFormatter stringFromDate:date]; // 将时间转化成字符串
    return dateString;
}

@end
