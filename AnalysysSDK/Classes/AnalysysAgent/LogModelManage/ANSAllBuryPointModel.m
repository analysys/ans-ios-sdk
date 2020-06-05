//
//  ANSAllBuryPointModel.m
//  AnalysysAgent
//
//  Created by xiao xu on 2019/10/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSAllBuryPointModel.h"

@interface ANSAllBuryPointModel()
@property (nonatomic, copy) NSString *channel;
@property (nonatomic, copy) NSString *time_zone;
@property (nonatomic, copy) NSString *manufacturer;
@property (nonatomic, copy) NSString *app_version;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *os;
@property (nonatomic, copy) NSString *os_version;
@property (nonatomic, copy) NSString *network;
@property (nonatomic, copy) NSString *carrier_name;
@property (nonatomic, copy) NSString *screen_width;
@property (nonatomic, copy) NSString *screen_height;
@property (nonatomic, copy) NSString *brand;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *is_first_day;
@property (nonatomic, copy) NSString *session_id;
@end

@implementation ANSAllBuryPointModel
- (NSDictionary *)toDictionary {
    NSMutableDictionary *totalDic = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    [totalDic setValue:@"$user_click" forKey:@"xwhat"];
    
    NSMutableDictionary *xContent = [NSMutableDictionary dictionary];
    [xContent setValue:[ANSLogParamsUtil getLib] forKey:ANSLib];
    [xContent setValue:[ANSLogParamsUtil getLibVersion] forKey:ANSLibVersion];
    [xContent setValue:[ANSLogParamsUtil getPlatform] forKey:ANSPlatform];
    [xContent setValue:[ANSLogParamsUtil getDebug] forKey:ANSDebug];
    [xContent setValue:[ANSLogParamsUtil getIsLogin] forKey:ANSIsLogin];
    [xContent setValue:[ANSLogParamsUtil getChannel] forKey:ANSChannel];
    [xContent setValue:[ANSLogParamsUtil getTimeZone] forKey:ANSTimeZone];
    [xContent setValue:[ANSLogParamsUtil getManufacturer] forKey:ANSManufacturer];
    [xContent setValue:[ANSLogParamsUtil getAppVersion] forKey:ANSAppVersion];
    [xContent setValue:[ANSLogParamsUtil getModel] forKey:ANSModel];
    [xContent setValue:[ANSLogParamsUtil getOS] forKey:ANSOS];
    [xContent setValue:[ANSLogParamsUtil getOSVersion] forKey:ANSOSVersion];
    [xContent setValue:[ANSLogParamsUtil getNetwork] forKey:ANSNetwork];
    [xContent setValue:[ANSLogParamsUtil getCarrierName] forKey:ANSCarrierName];
    [xContent setValue:[ANSLogParamsUtil getBrand] forKey:ANSBrand];
    [xContent setValue:[ANSLogParamsUtil getLanguage] forKey:ANSLanguage];
    [xContent setValue:[ANSLogParamsUtil getCarrierName] forKey:ANSCarrierName];
    [xContent setValue:[ANSLogParamsUtil getScreenWidth] forKey:ANSScreenWidth];
    [xContent setValue:[ANSLogParamsUtil getScreenHeight] forKey:ANSScreenHeight];
    [xContent setValue:[ANSLogParamsUtil getScreenWidth] forKey:ANSPageWidth];
    [xContent setValue:[ANSLogParamsUtil getScreenHeight] forKey:ANSPageHeight];
    [xContent setValue:[ANSLogParamsUtil getIsFirstDay] forKey:ANSIsFirstDay];
    [xContent setValue:[ANSLogParamsUtil getSessionID] forKey:ANSSessionID];
    [xContent setValue:self.url forKey:ANSUrl];
    [xContent setValue:self.title forKey:ANSTitle];
    [xContent setValue:self.element_id forKey:ANSElementID];
    [xContent setValue:self.element_type forKey:ANSElementType];
    [xContent setValue:self.element_path forKey:ANSElementPath];
    [xContent setValue:self.element_content forKey:ANSElementContent];
    [xContent setValue:self.element_position forKey:ANSElementPosition];
   
    [xContent addEntriesFromDictionary:[ANSLogParamsUtil getSuperProperties]];
    [totalDic setValue:xContent forKey:@"xcontext"];
    return totalDic;
}
@end
