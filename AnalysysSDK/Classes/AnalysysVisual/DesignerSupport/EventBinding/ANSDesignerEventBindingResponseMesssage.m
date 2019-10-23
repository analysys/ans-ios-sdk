//
//  ANSDesignerEventBindingResponseMesssage.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSDesignerEventBindingMessage.h"

@implementation ANSDesignerEventBindingResponseMessage

+ (instancetype)message {
    return [(ANSDesignerEventBindingResponseMessage *)[self alloc] initWithType:@"event_binding_response"];
}

- (void)setStatus:(NSString *)status {
    [self setPayloadObject:status forKey:@"status"];
}

- (NSString *)status {
    return [self payloadObjectForKey:@"status"];
}

@end
