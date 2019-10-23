//
//  ANSABTestDesignerMessage.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

/** 协议类 */

#import <Foundation/Foundation.h>

@class ANSABTestDesignerConnection;

@protocol ANSABTestDesignerMessage <NSObject>

//  可视化类型
//  1. "type": "event_binding_request"
@property (nonatomic, copy, readonly) NSString *type;

//  数据操作类型
//  1. "recordtype": "all"     websocket链接后增量下发
//  2. "recordtype": "save"    增加埋点数据
//  3. "recordtype": "update"  埋点数据修改
//  4. "recordtype": "delete"  删除埋点数据
@property (nonatomic, copy) NSString *operate;

- (void)setPayloadObject:(id)object forKey:(NSString *)key;
- (id)payloadObjectForKey:(NSString *)key;

- (NSData *)JSONData;

- (NSOperation *)responseCommandWithConnection:(ANSABTestDesignerConnection *)connection;

@end
