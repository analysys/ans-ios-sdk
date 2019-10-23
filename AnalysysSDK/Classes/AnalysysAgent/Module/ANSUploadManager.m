//
//  ANSUploadManager.m
//  AnalysysAgent
//
//  Created by analysys on 2018/3/1.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "ANSUploadManager.h"
#import <UIKit/UIKit.h>

//  数据请求类型
typedef NS_ENUM(NSInteger, AnsRequestType) {
    AnsRequestGet,
    AnsRequestPost
};

/** 超时时长 */
static double const ANSHttpRequestTimeOutInterval = 30.0;

@interface ANSUploadManager ()

@property (atomic, strong) NSURLSession *session;

@end



@implementation ANSUploadManager


- (instancetype)init {
    if (self = [super init]) {
        if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
            NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            sessionConfig.allowsCellularAccess = true;
            _session = [NSURLSession sessionWithConfiguration:sessionConfig];
        }
    }
    return self;
}

#pragma mark - public method

/** post请求 */
- (void)postRequestWithServerURLStr:(NSString *)URLStr
                             header:(NSDictionary *)header
                               body:(id)body
                            success:(SuccessBlock)successBlock
                            failure:(FailureBlock)failureBlock {
    [self requestWithServer:URLStr
                       type:AnsRequestPost
                 parameters:nil
                     header:header
                       body:body
                    success:successBlock
                    failure:failureBlock];
}

/** get请求 */
- (void)getRequestWithServerURLStr:(NSString *)URLStr
                        parameters:(NSDictionary *)parameters
                           success:(SuccessBlock)successBlock
                           failure:(FailureBlock)failureBlock {
    [self requestWithServer:URLStr
                       type:AnsRequestGet
                 parameters:parameters
                     header:nil
                       body:nil
                    success:successBlock
                    failure:failureBlock];
}

#pragma mark - private method

/** 拼接请求URL */
- (NSURL *)getHttpURLWithServer:(NSString *)serverUrl parameters:(NSDictionary *)parameters {
    NSString *paraStr;
    for (NSString *key in parameters.allKeys) {
        if (paraStr == nil) {
            paraStr = [NSString stringWithFormat:@"%@=%@",key,parameters[key]];
        } else {
            paraStr = [NSString stringWithFormat:@"%@&%@=%@",paraStr,key,parameters[key]];
        }
    }
    if (paraStr.length > 0) {
        serverUrl = [NSString stringWithFormat:@"%@?%@",serverUrl,paraStr];
    }
    NSURL *retUrl = [NSURL URLWithString:serverUrl];
    return retUrl;
}

/** body信息 */
- (NSString *)httpRequestBody:(id)body {
    NSString *bodyString;
    if ([body isKindOfClass:[NSString class]]) {
        bodyString = body;
    } else if ([body isKindOfClass:[NSDictionary class]]) {
        NSMutableArray *stringComponents = [NSMutableArray array];
        [body enumerateKeysAndObjectsUsingBlock:^(id nestedKey, id nestedValue, BOOL *stop){
            NSString *stringComponent = [NSString stringWithFormat:@"%@=%@", nestedKey, [nestedValue description]];
            [stringComponents addObject:stringComponent];
        }];
        bodyString = [stringComponents componentsJoinedByString:@"&"];
    } else {
        
    }
    return bodyString;
}

/** 发起请求 */
- (void)requestWithServer:(NSString *)server
                     type:(AnsRequestType)type
               parameters:(NSDictionary *)parameters
                   header:(NSDictionary *)header
                     body:(id)body
                  success:(SuccessBlock)successBlock
                  failure:(FailureBlock)failureBlock {
    NSURL *requestURL = [self getHttpURLWithServer:server parameters:parameters];
    if (requestURL == nil || requestURL.absoluteString.length == 0) {
        return;
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:ANSHttpRequestTimeOutInterval];
    
    if (type == AnsRequestGet) {
        request.HTTPMethod = @"GET";
    } else if (type == AnsRequestPost) {
        request.HTTPMethod = @"POST";
    }
    
    NSArray *headerKeys = [header allKeys];
    [headerKeys enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        [request setValue:header[key] forHTTPHeaderField:key];
    }];
    //  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //  request.allHTTPHeaderFields
    NSString *bodyStr = [self httpRequestBody:body];
    if (bodyStr) {
        [request setHTTPBody:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (_session) {
        NSURLSessionDataTask *sessionDataTask = [_session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            } else {
                if (successBlock) {
                    successBlock(response, data);
                }
            }
        }];
        
        [sessionDataTask resume];
    } else {
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable error) {
            if (error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            } else {
                if (successBlock) {
                    successBlock(response, data);
                }
            }
        }];
    }
}


@end
