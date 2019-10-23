//
//  ANSABTestDesignerDeviceInfoResponseMessage.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSABTestDesignerDeviceInfoResponseMessage.h"

@implementation ANSABTestDesignerDeviceInfoResponseMessage


+ (instancetype)message {
    // TODO: provide a payload
    return [(ANSABTestDesignerDeviceInfoResponseMessage *)[self alloc] initWithType:@"device_info_response"];
}

-(NSString *)deviceType {
    return [self payloadObjectForKey:@"device_type"];
}

-(void)setDeviceType:(NSString *)deviceType {
    [self setPayloadObject:deviceType forKey:@"device_type"];
}

- (NSString *)systemName {
    return [self payloadObjectForKey:@"system_name"];
}

- (void)setSystemName:(NSString *)systemName {
    [self setPayloadObject:systemName forKey:@"system_name"];
}

- (NSString *)systemVersion {
    return [self payloadObjectForKey:@"system_version"];
}

- (void)setSystemVersion:(NSString *)systemVersion {
    [self setPayloadObject:systemVersion forKey:@"system_version"];
}

- (NSString *)appVersion {
    return [self payloadObjectForKey:@"app_version"];
}

- (void)setAppVersion:(NSString *)appVersion {
    [self setPayloadObject:appVersion forKey:@"app_version"];
}

- (NSString *)appBuild {
    return [self payloadObjectForKey:@"appBuild"];
}

-(void)setAppBuild:(NSString *)appBuild {
    [self setPayloadObject:appBuild forKey:@"appBuild"];
}

- (NSString *)deviceName {
    return [self payloadObjectForKey:@"device_name"];
}

- (void)setDeviceName:(NSString *)deviceName {
    [self setPayloadObject:deviceName forKey:@"device_name"];
}

- (NSString *)libVersion {
    return [self payloadObjectForKey:@"lib_version"];
}

- (void)setLibVersion:(NSString *)libVersion {
    [self setPayloadObject:libVersion forKey:@"lib_version"];
}

- (NSString *)deviceModel {
    return [self payloadObjectForKey:@"device_model"];
}

- (void)setDeviceModel:(NSString *)deviceModel {
    [self setPayloadObject:deviceModel forKey:@"device_model"];
}

-(NSString *)idfv {
    return [self payloadObjectForKey:@"device_id"];
}

-(void)setIdfv:(NSString *)idfv {
    [self setPayloadObject:idfv forKey:@"device_id"];
}

- (NSArray *)availableFontFamilies {
    return [self payloadObjectForKey:@"available_font_families"];
}

- (void)setAvailableFontFamilies:(NSArray *)availableFontFamilies {
    [self setPayloadObject:availableFontFamilies forKey:@"available_font_families"];
}

- (NSString *)mainBundleIdentifier {
    return [self payloadObjectForKey:@"main_bundle_identifier"];
}

- (void)setMainBundleIdentifier:(NSString *)mainBundleIdentifier {
    [self setPayloadObject:mainBundleIdentifier forKey:@"main_bundle_identifier"];
}

- (void)setWidth:(CGFloat)width {
    [self setPayloadObject:[NSNumber numberWithFloat:width] forKey:@"width"];
}

-(CGFloat)width {
    return [[self payloadObjectForKey:@"width"] floatValue];
}

-(void)setHeight:(CGFloat)height {
    [self setPayloadObject:[NSNumber numberWithFloat:height] forKey:@"height"];
}

-(CGFloat)height {
    return [[self payloadObjectForKey:@"height"] floatValue];
}


@end
