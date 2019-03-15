//
//  ANSLocationManager.m
//  Analysys_CMB
//
//  Created by SoDo on 2019/1/16.
//  Copyright © 2019 analysys. All rights reserved.
//

#import "ANSLocationManager.h"
#import <CoreLocation/CoreLocation.h>

@interface ANSLocationManager ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation ANSLocationManager

+ (instancetype)shareInstance {
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
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        //  控制定位精度,越高耗电量越
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.locationManager.distanceFilter = 10.0f;
    }
    return self;
}

- (void)startMonitorLocation {
    if (![CLLocationManager locationServicesEnabled]) {
        //  是否支持定位
        return;
    }
    
    //  用户已经授权定位服务
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    }
    //    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways ||
    //        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
    //        if (@available(iOS 8.0, *)) {
    //
    //            [self.locationManager requestAlwaysAuthorization];
    //        }
    //        NSLog(@"----------------请求定位----------------");
    //    }
}

#pragma mark *** CLLocationManagerDelegate ***

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    if ([error code] == kCLErrorDenied) {
        NSLog(@"访问被拒绝");
    }
    if ([error code] == kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息");
    }
}


//定位代理经纬度回调
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *curLocation = locations[0];
    NSString *longitude = [NSString stringWithFormat:@"%lf", curLocation.coordinate.longitude];
    NSString *latitude = [NSString stringWithFormat:@"%lf", curLocation.coordinate.latitude];
    NSLog(@"--------位置获取完成: %@ - %@ --------",longitude,latitude);
}


-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"--------%s--------",__FUNCTION__);
}

@end
