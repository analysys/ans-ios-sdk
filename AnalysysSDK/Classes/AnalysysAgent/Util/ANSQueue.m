//
//  ANSQueue.m
//  AnalysysAgent
//
//  Created by xiao xu on 2019/10/11.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSQueue.h"


static dispatch_queue_t ans_log_queue() {
    static dispatch_queue_t _ans_serial_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ans_serial_queue = dispatch_queue_create("com.analysys.logDataQueue", DISPATCH_QUEUE_SERIAL);
    });
    return _ans_serial_queue;
}


static dispatch_queue_t ans_request_queue() {
    static dispatch_queue_t _ans_request_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ans_request_queue = dispatch_queue_create("com.analysys.requestQueue", DISPATCH_QUEUE_SERIAL);
    });
    return _ans_request_queue;
}

@implementation ANSQueue

+ (void)dispatchAsyncLogSerialQueueWithBlock:(void(^)(void))dispatchBlock {
    dispatch_async(ans_log_queue(), dispatchBlock);
}

+ (void)dispatchSyncLogSerialQueueWithBlock:(void(^)(void))dispatchBlock {
    dispatch_sync(ans_log_queue(), dispatchBlock);
}

+ (void)dispatchAfterSeconds:(float)second
onLogSerialQueueWithBlock:(void(^)(void))dispatchBlock {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), ans_log_queue(), dispatchBlock);
}

+ (void)dispatchRequestSerialQueueWithBlock:(void(^)(void))dispatchBlock {
    dispatch_async(ans_request_queue(), dispatchBlock);
}

@end
