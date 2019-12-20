//
//  ANSBaseModel.h
//  AnalysysAgent
//
//  Created by xiao xu on 2019/10/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANSKeyNameConst.h"
#import "ANSLogParamsUtil.h"
NS_ASSUME_NONNULL_BEGIN

@interface ANSBaseModel : NSObject
@property (nonatomic, copy) NSString *appid;
@property (nonatomic, copy) NSString *xwho;
@property (nonatomic, copy) NSString *xwhat;
@property (nonatomic, copy) NSString *xwhen;
@property (nonatomic, copy) NSString *lib;
@property (nonatomic, copy) NSString *lib_version;
@property (nonatomic, copy) NSString *platform;
@property (nonatomic, copy) NSString *debug;
@property (nonatomic, copy) NSString *is_login;
- (NSDictionary *)toDictionary;
@end

NS_ASSUME_NONNULL_END
