//
//  ANSTelephonyNetwork.h
//  AnalysysAgent
//
//  Created by analysys on 2018/3/8.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * @class
 * ANSTelephonyNetwork
 *
 * @abstract
 * 网络模块
 *
 * @discussion
 * 网络监测及当前网络状态信息
 */

@interface ANSTelephonyNetwork : NSObject

+ (instancetype)shareInstance;

/**
 开启网络变化监测
 */
- (void)startReachability;

/**
 当前是否存在网络

 @return result
 */
- (BOOL)hasNetwork;

/**
 当前是否WIFI状态

 @return Y/N
 */
- (BOOL)isWIFI;

/**
 当前是否蜂窝数据状态

 @return Y/N
 */
- (BOOL)isCellular;

/**
 当前网络状态值

 @return status
 */
- (NSString *)telephonyNetworkDescrition;


@end
