//
//  AnalysysDataCache.h
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/23.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnalysysDataCache : NSObject

+ (void)set_appkey:(NSString *)appkey;
+ (NSString *)get_appkey;

+ (void)set_channel:(NSString *)channel;
+ (NSString *)get_channel;

+ (void)set_upload_url:(NSString *)upload_url;
+ (NSString *)get_upload_url;

+ (void)set_debug_url:(NSString *)debug_url;
+ (NSString *)get_debug_url;

+ (void)set_config_url:(NSString *)config_url;
+ (NSString *)get_config_url;
@end

NS_ASSUME_NONNULL_END
