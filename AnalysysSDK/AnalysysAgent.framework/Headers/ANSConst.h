//
//  ANSConst+private.h
//  AnalysysAgent
//
//  Created by 向作为 on 2019/6/24.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#ifndef ANSConst_h
#define ANSConst_h

/**
 Debug模式，上线时使用 AnalysysDebugOff
 
 - AnalysysDebugOff: 关闭Debug模式
 - AnalysysDebugOnly: 打开Debug模式，但该模式下发送的数据仅用于调试，不进行数据导入
 - AnalysysDebugButTrack: 打开Debug模式，并入库计算
 */
typedef NS_ENUM(NSInteger, AnalysysDebugMode) {
    AnalysysDebugOff = 0,
    AnalysysDebugOnly = 1,
    AnalysysDebugButTrack = 2
};

/**
 数据上传加密类型
 
 - AnalysysEncryptAES: AES ECB加密
 - AnalysysEncryptAESCBC128: AES CBC加密
 */
typedef NS_ENUM(NSInteger, AnalysysEncryptType) {
    AnalysysEncryptAES = 1,
    AnalysysEncryptAESCBC128 = 2
};

/**
 推送类型
 
 - AnalysysPushJiGuang: 极光推送
 - AnalysysPushGeTui: 个推推送
 - AnalysysPushBaiDu: 百度推送
 - AnalysysPushXiaoMi: 小米推送
 - AnalysysPushXinGe: 信鸽推送
 - AnalysysPushAPNS: APNS推送
 - AnalysysPushALi: 阿里推送
 */
typedef NS_ENUM(NSInteger, AnalysysPushProvider) {
    AnalysysPushJiGuang = 0,
    AnalysysPushGeTui,
    AnalysysPushBaiDu,
    AnalysysPushXiaoMi,
    AnalysysPushXinGe,
    AnalysysPushAPNS,
    AnalysysPushALi
};

/**
 允许数据上传的网络类型
 
 - AnalysysNetworkNONE: 不允许上传
 - AnalysysNetworkWWAN: 移动网络
 - AnalysysNetworkWIFI: WIFI网络
 - AnalysysNetworkALL: 有网络即可
 */
typedef NS_ENUM(NSInteger, AnalysysNetworkType) {
    AnalysysNetworkNONE = 1<<0,
    AnalysysNetworkWWAN = 1<<1,
    AnalysysNetworkWIFI = 1<<2,
    AnalysysNetworkALL = 0xFF
};

#endif /* ANSConst_h */
