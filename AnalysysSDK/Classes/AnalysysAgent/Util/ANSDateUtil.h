//
//  ANSDateUtil.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/10/29.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANSDateUtil : NSObject

/// 通用时间格式化
+ (NSDateFormatter *)dateFormat;

/// 时间校准格式化
+ (NSDateFormatter *)timeCheckFormat;

/// 转换时间为当前时区时间
/// @param date 需转换时间
+ (NSDate *)convertToLocalDate:(NSDate *)date;


@end


