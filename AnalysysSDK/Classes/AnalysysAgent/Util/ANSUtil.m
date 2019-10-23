//
//  ANSUtil.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/2/23.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSUtil.h"

@implementation ANSUtil

+ (long long)nowTimeMilliseconds {
    NSDate *date = [NSDate date];
    NSTimeInterval nowtime = [date timeIntervalSince1970]*1000;
    long long timeLongValue = [[NSNumber numberWithDouble:nowtime] longLongValue];
    return timeLongValue;
}

+ (NSString *)getHttpUrlString:(NSString *)urlString {
    if (![urlString hasPrefix:@"https://"] && ![urlString hasPrefix:@"http://"] ) {
        return @"";
    }
    return [self getRightUrlWithString:urlString];
}

+ (NSString *)getSocketUrlString:(NSString *)urlString {
    if (![urlString hasPrefix:@"ws://"] && ![urlString hasPrefix:@"wss://"] ) {
        return @"";
    }
    return [self getRightUrlWithString:urlString];
}

+ (NSString *)getRightUrlWithString:(NSString *)urlString {
    while (1) {
        if (![urlString hasSuffix:@"/"]) {
            break;
        }
        urlString = [urlString substringToIndex:urlString.length - 1];
    }
    return urlString;
}


+ (NSString *)subByteString:(NSString *)string byteLength:(NSInteger )length {
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    NSData* data = [string dataUsingEncoding:enc];
    
    NSData *subData = [data subdataWithRange:NSMakeRange(0, length)];
    NSString*txt=[[NSString alloc] initWithData:subData encoding:enc];
    
    //utf8 汉字占三个字节，表情占四个字节，可能截取失败
    NSInteger index = 1;
    while (index <= 3 && !txt) {
        if (length > index) {
            subData = [data subdataWithRange:NSMakeRange(0, length - index)];
            txt = [[NSString alloc] initWithData:subData encoding:enc];
        }
        index ++;
    }
    
    if (!txt) {
        return string;
    }
    return txt;
}


@end
