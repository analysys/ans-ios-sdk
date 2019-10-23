//
//  ANSABTestDesignerDeviceInfoRequestMessage.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSABTestDesignerDeviceInfoRequestMessage.h"

#import "ANSABTestDesignerConnection.h"
#import "ANSABTestDesignerDeviceInfoResponseMessage.h"
#import <UIKit/UIKit.h>
#import "ANSDeviceInfo.h"
#import "ANSConst+private.h"

NSString *const ANSDesignerDeviceInfoRequestMessageType = @"device_info_request";

@implementation ANSABTestDesignerDeviceInfoRequestMessage


+ (instancetype)message {
    return [(ANSABTestDesignerDeviceInfoRequestMessage *)[self alloc] initWithType:ANSDesignerDeviceInfoRequestMessageType];
}

/** 发送设备基本信息 */
- (NSOperation *)responseCommandWithConnection:(ANSABTestDesignerConnection *)connection {
    __weak ANSABTestDesignerConnection *weak_connection = connection;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        __strong ANSABTestDesignerConnection *conn = weak_connection;
        
        ANSABTestDesignerDeviceInfoResponseMessage *deviceInfoResponseMessage = [ANSABTestDesignerDeviceInfoResponseMessage message];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            deviceInfoResponseMessage.deviceType = @"iPhone";
            deviceInfoResponseMessage.systemName = [ANSDeviceInfo getSystemName];
            deviceInfoResponseMessage.systemVersion = [ANSDeviceInfo getSystemVersion];
            deviceInfoResponseMessage.deviceName = [ANSDeviceInfo getDeviceName];
            deviceInfoResponseMessage.deviceModel = [ANSDeviceInfo getDeviceModel];
            deviceInfoResponseMessage.appBuild = [ANSDeviceInfo getBundleId];
            deviceInfoResponseMessage.idfv = [ANSDeviceInfo getIdfv];
            deviceInfoResponseMessage.appVersion = [ANSDeviceInfo getAppVersion];
            deviceInfoResponseMessage.libVersion = ANSSDKVersion;
            deviceInfoResponseMessage.mainBundleIdentifier = [ANSDeviceInfo getBundleId];
//            deviceInfoResponseMessage.availableFontFamilies = [self availableFontFamilies];
            CGRect rect_screen = [[UIScreen mainScreen] bounds];
            deviceInfoResponseMessage.width = rect_screen.size.width;
            deviceInfoResponseMessage.height = rect_screen.size.height;
        });
        
        [conn sendMessage:deviceInfoResponseMessage];
    }];
    
    return operation;
}

- (NSArray *)availableFontFamilies {
    NSMutableDictionary *fontFamilies = [NSMutableDictionary dictionary];
    
    // Get all the font families and font names.
    for (NSString *familyName in [UIFont familyNames]) {
        fontFamilies[familyName] = [self fontDictionaryForFontFamilyName:familyName fontNames:[UIFont fontNamesForFamilyName:familyName]];
    }
    
    // For the system fonts update the font families.
    NSArray *systemFonts = @[[UIFont systemFontOfSize:17.0f],
                             [UIFont boldSystemFontOfSize:17.0f],
                             [UIFont italicSystemFontOfSize:17.0f]];
    
    for (UIFont *systemFont in systemFonts) {
        NSString *familyName = systemFont.familyName;
        NSString *fontName = systemFont.fontName;
        
        NSMutableDictionary *font = fontFamilies[familyName];
        if (font) {
            NSMutableArray *fontNames = font[@"font_names"];
            if ([fontNames containsObject:fontName] == NO) {
                [fontNames addObject:fontName];
            }
        } else {
            fontFamilies[familyName] = [self fontDictionaryForFontFamilyName:familyName fontNames:@[fontName]];
        }
    }
    
    return fontFamilies.allValues;
}

- (NSMutableDictionary *)fontDictionaryForFontFamilyName:(NSString *)familyName fontNames:(NSArray *)fontNames {
    return [@{
              @"family": familyName,
              @"font_names": [fontNames mutableCopy]
              } mutableCopy];
}


@end
