//
//  AnalysysDataCache.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/23.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "AnalysysDataCache.h"

static NSString *const analysys_sdk_appkey = @"analysys_sdk_appkey";
static NSString *const analysys_sdk_channel = @"analysys_sdk_channel";
static NSString *const analysys_sdk_upload_url = @"analysys_sdk_upload_url";
static NSString *const analysys_sdk_debug_url = @"analysys_sdk_debug_url";
static NSString *const analysys_sdk_config_url = @"analysys_sdk_config_url";

@implementation AnalysysDataCache

+ (void)set_appkey:(NSString *)appkey {
    if (appkey) {
        [[NSUserDefaults standardUserDefaults] setObject:appkey forKey:analysys_sdk_appkey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
+ (NSString *)get_appkey {
    return [[NSUserDefaults standardUserDefaults] objectForKey:analysys_sdk_appkey];
}

+ (void)set_channel:(NSString *)channel {
    if (channel) {
        [[NSUserDefaults standardUserDefaults] setObject:channel forKey:analysys_sdk_channel];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
+ (NSString *)get_channel {
    return [[NSUserDefaults standardUserDefaults] objectForKey:analysys_sdk_channel];
}

+ (void)set_upload_url:(NSString *)upload_url {
    if (upload_url) {
        [[NSUserDefaults standardUserDefaults] setObject:upload_url forKey:analysys_sdk_upload_url];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
+ (NSString *)get_upload_url {
    return [[NSUserDefaults standardUserDefaults] objectForKey:analysys_sdk_upload_url];
}

+ (void)set_debug_url:(NSString *)debug_url {
    if (debug_url) {
        [[NSUserDefaults standardUserDefaults] setObject:debug_url forKey:analysys_sdk_debug_url];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
+ (NSString *)get_debug_url {
    return [[NSUserDefaults standardUserDefaults] objectForKey:analysys_sdk_debug_url];
}

+ (void)set_config_url:(NSString *)config_url {
    if (config_url) {
        [[NSUserDefaults standardUserDefaults] setObject:config_url forKey:analysys_sdk_config_url];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
+ (NSString *)get_config_url {
    return [[NSUserDefaults standardUserDefaults] objectForKey:analysys_sdk_config_url];
}

@end
