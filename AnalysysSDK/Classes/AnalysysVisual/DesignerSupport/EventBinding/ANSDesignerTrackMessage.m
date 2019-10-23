//
//  ANSDesignerTrackMessage.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSDesignerEventBindingMessage.h"
#import "ANSConsoleLog.h"

@implementation ANSDesignerTrackMessage {
    NSDictionary *_payload;
}

+ (instancetype)message {
    return [(ANSDesignerTrackMessage *)[self alloc] initWithType:@"track_message"];
}

+ (instancetype)messageWithPayload:(NSDictionary *)payload {
    return [(ANSDesignerTrackMessage *)[self alloc] initWithType:@"track_message" andPayload:payload];
}

- (instancetype)initWithType:(NSString *)type {
    return [self initWithType:type andPayload:@{}];
}

- (instancetype)initWithType:(NSString *)type andPayload:(NSDictionary *)payload {
    if (self = [super initWithType:type]) {
        _payload = payload;
    }
    return self;
}

- (NSData *)JSONData {
    NSDictionary *jsonObject = @{ @"type": self.type, @"payload": [_payload copy] };
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:(NSJSONWritingOptions)0 error:&error];
    if (error) {
        AnsDebug(@"Failed to serialize test designer message: %@", error);
    }
    
    return jsonData;
}

@end
