//
//  ANSTelephonyNetwork.m
//  AnalysysAgent
//
//  Created by analysys on 2018/3/8.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "ANSTelephonyNetwork.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "ANSReachability.h"
#import <UIKit/UIKit.h>

@implementation ANSTelephonyNetwork {
    ANSReachability *_reachability;
    
}
static CTTelephonyNetworkInfo *_networkInfo = nil;
+ (instancetype)shareInstance {
    static ANSTelephonyNetwork *instance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[ANSTelephonyNetwork alloc] init];
        _networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    });
    return instance;
}

#pragma mark - public method

- (void)startReachability {
    _reachability = [ANSReachability reachabilityForInternetConnection];
    [_reachability startNotifier];
}

- (BOOL)hasNetwork {
    return ANSNotReachable != [_reachability networkStatus];
}

- (BOOL)isWIFI {
    return ANSReachableViaWiFi == [_reachability networkStatus];
}

- (BOOL)isCellular {
    return ANSReachableViaWWAN == [_reachability networkStatus];
}

- (NSString *)telephonyNetworkDescrition {
    ANSNetworkStatus status = [_reachability networkStatus];
    NSString *network = nil;
    @try {
        if (status == ANSReachableViaWiFi) {
            network = @"WIFI";
        } else if (status == ANSReachableViaWWAN) {
            if (@available(iOS 12.0, *)) {
                network = _networkInfo.serviceCurrentRadioAccessTechnology.allValues.lastObject;
            }
            if (!network) {
                network = _networkInfo.currentRadioAccessTechnology;
            }
        }
        if (!network) {
            network = @"NO_NETWORK";
        }
    } @catch (NSException *exception) {
        NSLog(@"telephonyNetworkDescrition get exception:%@",exception.description);
    }
    return network;
}

@end
