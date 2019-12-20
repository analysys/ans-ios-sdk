//
//  ANSBaseModel.m
//  AnalysysAgent
//
//  Created by xiao xu on 2019/10/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSBaseModel.h"

@implementation ANSBaseModel
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:[ANSLogParamsUtil getAppID] forKey:@"appid"];
    [dic setValue:[ANSLogParamsUtil getXwho] forKey:@"xwho"];
    [dic setValue:[ANSLogParamsUtil getXwhen] forKey:@"xwhen"];
    return dic;
}
@end
