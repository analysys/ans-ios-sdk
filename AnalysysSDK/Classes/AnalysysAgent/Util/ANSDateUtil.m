//
//  ANSDateUtil.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/10/29.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSDateUtil.h"

static NSDateFormatter *dateFormatter = nil;
static NSDateFormatter *timeCheckFormatter = nil;

@implementation ANSDateUtil

+ (NSDateFormatter *)dateFormat {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    });
    return dateFormatter;
}

+ (NSDateFormatter *)timeCheckFormat {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        timeCheckFormatter = [[NSDateFormatter alloc] init];
        [timeCheckFormatter setTimeStyle:NSDateFormatterFullStyle];
        [timeCheckFormatter setDateFormat:@"EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"];
        [timeCheckFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
        [timeCheckFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"]];
    });
    return timeCheckFormatter;
}

+ (NSDate *)convertToLocalDate:(NSDate *)date {
    NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone *destinationTimeZone = [NSTimeZone localTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:date];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate *destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:date];
    return destinationDateNow;
}

@end
