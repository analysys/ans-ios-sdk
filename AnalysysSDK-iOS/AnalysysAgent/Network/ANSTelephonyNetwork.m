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
#import "ANSConsleLog.h"

@implementation ANSTelephonyNetwork {
    ANSReachability *_reachability;
}

+ (instancetype)shareInstance {
    static ANSTelephonyNetwork *instance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[ANSTelephonyNetwork alloc] init];
    });
    return instance;
}

#pragma mark *** public method ***

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
    NSString *network = @"NO_NETWORK";
    if (status == ANSReachableViaWiFi) {
        network = @"WIFI";
    } else if (status == ANSReachableViaWWAN) {
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        network = networkInfo.currentRadioAccessTechnology;
    }
    return network;
}


@end
