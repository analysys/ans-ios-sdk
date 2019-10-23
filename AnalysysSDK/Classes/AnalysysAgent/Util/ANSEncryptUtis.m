//
//  ANSEncryptUtis.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/10/16.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSEncryptUtis.h"

#import "AnalysysAgentConfig.h"
#import "ANSStrategyManager.h"
#import "ANSGzip.h"
#import "ANSModuleProcessing.h"
#import "ANSConst+private.h"

@implementation ANSEncryptUtis


+ (NSDictionary *)httpHeaderInfo {
    NSMutableDictionary *httpHeader = [NSMutableDictionary dictionary];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *policyVersion = [[ANSStrategyManager sharedManager] getServerhashCodeValue];
    NSString *spv = [NSString stringWithFormat:@"iOS|%@|%@|%@|%@", AnalysysConfig.appKey, ANSSDKVersion, policyVersion, appVersion];
    NSData *spvData = [spv dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Spv = [spvData base64EncodedStringWithOptions:0];
    [httpHeader setValue:base64Spv forKey:@"spv"];
    
    //  额外header
    NSDictionary *extroHeader = [ANSModuleProcessing extroHeaderInfo];
    [httpHeader addEntriesFromDictionary:extroHeader];
    
    return [httpHeader copy];
}

+ (NSString *)processUploadBody:(NSString *)bodyJson param:(NSDictionary *)param {
    NSString *uploadString = [ANSModuleProcessing encryptJsonString:bodyJson param:param];
    return [self zipAndBase64WithString:uploadString];
}

/** 数据 压缩 -> base64 */
+ (NSString *)zipAndBase64WithString:(NSString *)jsonStr {
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *zipData = [ANSGzip gzipData:jsonData];
    return [zipData base64EncodedStringWithOptions:0];
}

@end
