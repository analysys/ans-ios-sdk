//
//  ANSDeviceInfo.m
//  AnalysysAgent
//
//  Created by SoDo on 2018/11/22.
//  Copyright © 2018 analysys. All rights reserved.
//

#import "ANSDeviceInfo.h"

#import <sys/sysctl.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation ANSDeviceInfo

+ (instancetype)sharedManager {
    static id singleInstance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        singleInstance = [[self alloc] init] ;
    });
    return singleInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeZoneDidChanged:) name:NSSystemTimeZoneDidChangeNotification object:nil];
        
        _systemName = [UIDevice currentDevice].systemName;
        _systemVersion = [UIDevice currentDevice].systemVersion;
        _deviceName = [UIDevice currentDevice].name;
        _language = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject];
        _model = [UIDevice currentDevice].model;
        _bundleId = [[NSBundle mainBundle] bundleIdentifier];
        _deviceModel = [self deviceModel];
        _appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        _appBulidVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        _osVersion = [[UIDevice currentDevice] systemVersion];
        _idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        
        CGRect rect_screen = [[UIScreen mainScreen] bounds];
        _screenWidth = rect_screen.size.width;
        _screenHeight = rect_screen.size.height;
        
        [self setSystemTimeZone];
        
        [self setMobileOperatorInfo];
    }
    return self;
}

- (NSString *)deviceModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char answer[size];
    sysctlbyname("hw.machine", answer, &size, NULL, 0);
    NSString *model = @(answer);
    return model;
}

/** 时区 */
- (void)setSystemTimeZone {
    NSString *timeZone = [[NSTimeZone localTimeZone] localizedName:NSTimeZoneNameStyleStandard locale:[NSLocale systemLocale]];
    if ([timeZone isEqualToString:@"GMT"]) {
        timeZone = @"GMT+00:00";
    }
    _timeZone = timeZone;
}

/** 运营商信息 */
- (void)setMobileOperatorInfo {
    if ([NSThread isMainThread]) {
        CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [info subscriberCellularProvider];
        if ([carrier mobileNetworkCode]) {
            _carrierName = carrier.carrierName;
        } else {
            _carrierName = nil;
        }
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self setMobileOperatorInfo];
        });
    }
}

#pragma mark *** notification ***

- (void)timeZoneDidChanged:(NSNotification *)notification {
    [self setSystemTimeZone];
}


@end
