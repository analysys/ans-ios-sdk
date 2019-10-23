//
//  ANSAbstractABTestDesignerMessage.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSAbstractABTestDesignerMessage.h"
#import "ANSConsoleLog.h"

@interface ANSAbstractABTestDesignerMessage ()

@property (nonatomic, copy, readwrite) NSString *type;

@end



@implementation ANSAbstractABTestDesignerMessage {
    NSMutableDictionary *_payload;
}

+ (instancetype)messageWithType:(NSString *)type payload:(NSDictionary *)payload
{
    return [(ANSAbstractABTestDesignerMessage *)[self alloc] initWithType:type payload:payload];
}

- (instancetype)initWithType:(NSString *)type
{
    return [self initWithType:type payload:@{}];
}

- (instancetype)initWithType:(NSString *)type payload:(NSDictionary *)payload
{
    self = [super init];
    if (self) {
        _type = type;
        _payload = [payload mutableCopy];
    }
    
    return self;
}

- (void)setPayloadObject:(id)object forKey:(NSString *)key
{
    _payload[key] = object ?: [NSNull null];
}

- (id)payloadObjectForKey:(NSString *)key
{
    id object = _payload[key];
    return [object isEqual:[NSNull null]] ? nil : object;
}

- (NSDictionary *)payload
{
    return [_payload copy];
}

- (NSData *)JSONData
{
    NSDictionary *jsonObject = @{ @"type": _type, @"payload": [_payload copy] };
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:(NSJSONWritingOptions)0 error:&error];
    if (error) {
        AnsDebug(@"Failed to serialize test designer message: %@", error);
    }
    
    return jsonData;
}

- (NSOperation *)responseCommandWithConnection:(ANSABTestDesignerConnection *)connection
{
    return nil;
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@:%p type='%@'>", NSStringFromClass([self class]), (__bridge void *)self, self.type];
}


@end
