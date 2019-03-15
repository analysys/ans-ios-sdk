//
//  ANSUploadManager.m
//  AnalysysAgent
//
//  Created by analysys on 2018/3/1.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "ANSUploadManager.h"
#import <UIKit/UIKit.h>
#import "ANSConsleLog.h"

//  数据请求类型
typedef enum : NSUInteger {
    AnsRequestGet,
    AnsRequestPost
} AnsRequestType;

/** 超时时长 */
static double const AnsTimeOutInterval = 30.0;

@interface ANSUploadManager ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, assign) AnsRequestType requestType;
@property (nonatomic, strong) NSDictionary *header;
@property (nonatomic, assign) id requestBody;


@end



@implementation ANSUploadManager

+ (instancetype)shareInstance {
    static ANSUploadManager *instance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[ANSUploadManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
            NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            sessionConfig.allowsCellularAccess = true;
            _session = [NSURLSession sessionWithConfiguration:sessionConfig];
        }
        _requestType = AnsRequestPost;
    }
    return self;
}

#pragma mark *** public method ***

/** post请求 */
+ (void)postRequestWithServerURLStr:(NSString *)URLStr
                             header:(NSDictionary *)header
                               body:(id)body
                            success:(SuccessBlock)successBlock
                            failure:(FailureBlock)failureBlock {
    [[ANSUploadManager shareInstance] requestWithServer:URLStr
                                                      type:AnsRequestPost
                                                parameters:nil
                                                    header:header
                                                      body:body
                                                   success:successBlock
                                                   failure:failureBlock];
}

/** get请求 */
+ (void)getRequestWithServerURLStr:(NSString *)URLStr
                        parameters:(NSDictionary *)parameters
                           success:(SuccessBlock)successBlock
                           failure:(FailureBlock)failureBlock {
    [[ANSUploadManager shareInstance] requestWithServer:URLStr
                                                      type:AnsRequestGet
                                                parameters:parameters
                                                    header:nil
                                                      body:nil
                                                   success:successBlock
                                                   failure:failureBlock];
}

#pragma mark *** private method ***

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
    
    return [NSURL URLWithString:serverUrl];
}

/** body信息 */
- (NSString *)httpRequestBody {
    NSString *bodyString;
    if ([self.requestBody isKindOfClass:[NSString class]]) {
        bodyString = self.requestBody;
    } else if ([self.requestBody isKindOfClass:[NSDictionary class]]) {
        NSMutableArray *stringComponents = [NSMutableArray array];
        [self.requestBody enumerateKeysAndObjectsUsingBlock:^(id nestedKey, id nestedValue, BOOL *stop){
            NSString *stringComponent = [NSString stringWithFormat:@"%@=%@", nestedKey, [nestedValue description]];
            [stringComponents addObject:stringComponent];
        }];
        bodyString = [stringComponents componentsJoinedByString:@"&"];
    } else {
        
    }
    return bodyString;
}

/** 拼接request对象 */
- (NSMutableURLRequest *)getRequestWithURL:(NSURL *)url {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:AnsTimeOutInterval];
    if (self.requestType == AnsRequestGet) {
        request.HTTPMethod = @"GET";
    } else if (self.requestType == AnsRequestPost) {
        request.HTTPMethod = @"POST";
    }
    
    NSArray *headerKeys = [self.header allKeys];
    [headerKeys enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        [request setValue:self.header[key] forHTTPHeaderField:key];
    }];
    //  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //  request.allHTTPHeaderFields
    NSString *bodyStr = [self httpRequestBody];
    if (bodyStr) {
        [request setHTTPBody:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return request;
}

/** 发起请求 */
- (void)requestWithServer:(NSString *)server
                     type:(AnsRequestType)type
               parameters:(NSDictionary *)parameters
                   header:(NSDictionary *)header
                     body:(id)body
                  success:(SuccessBlock)successBlock
                  failure:(FailureBlock)failureBlock {
    @try {
        NSURL *requestURL = [self getHttpURLWithServer:server parameters:parameters];
        self.header = [header copy];
        self.requestBody = body;
        self.requestType = type;
        NSMutableURLRequest *request = [self getRequestWithURL:requestURL];
        if (_session) {
            NSURLSessionDataTask *sessionDataTask = [_session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                    AnsError(@"Send request error: %@",error.localizedDescription);
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
                    AnsError(@"Send request error: %@",error.localizedDescription);
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
    } @catch (NSException *exception) {
        AnsError(@"Upload server exception: %@", exception);
    }
}


@end
