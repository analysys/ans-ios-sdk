//
//  ANSAbstractABTestDesignerMessage.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

/** 基类 */

#import <Foundation/Foundation.h>
#import "ANSABTestDesignerMessage.h"

@interface ANSAbstractABTestDesignerMessage : NSObject<ANSABTestDesignerMessage>

@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy) NSString *operate;

+ (instancetype)messageWithType:(NSString *)type payload:(NSDictionary *)payload;

- (instancetype)initWithType:(NSString *)type;
- (instancetype)initWithType:(NSString *)type payload:(NSDictionary *)payload;

- (void)setPayloadObject:(id)object forKey:(NSString *)key;
- (id)payloadObjectForKey:(NSString *)key;
- (NSDictionary *)payload;

- (NSData *)JSONData;

@end
