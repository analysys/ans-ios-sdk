//
//  ANSABTestDesignerSnapshotRequestMessage.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSABTestDesignerSnapshotRequestMessage.h"

#import "ANSABTestDesignerConnection.h"
#import "ANSABTestDesignerSnapshotResponseMessage.h"
#import "ANSApplicationStateSerializer.h"
#import "ANSObjectIdentityProvider.h"
#import "ANSObjectSerializerConfig.h"
#import "AnalysysLogger.h"

NSString * const ANSDesignerSnapshotRequestMessageType = @"snapshot_request";
static NSString * const ANSSnapshotSerializerConfigKey = @"snapshot_class_descriptions";
static NSString * const ANSObjectIdentityProviderKey = @"object_identity_provider";


@implementation ANSABTestDesignerSnapshotRequestMessage


+ (instancetype)message {
    return [(ANSABTestDesignerSnapshotRequestMessage *)[self alloc] initWithType:ANSDesignerSnapshotRequestMessageType];
}

- (ANSObjectSerializerConfig *)configuration {
    NSDictionary *config = [self payloadObjectForKey:@"config"];
    return config ? [[ANSObjectSerializerConfig alloc] initWithDictionary:config] : nil;
}

- (NSOperation *)responseCommandWithConnection:(ANSABTestDesignerConnection *)connection {
    ANSDebug(@"uploadStatus - %d",connection.appStatus);
    
    //  服务器下发需要获取的config信息(enums/classes)
    __block ANSObjectSerializerConfig *serializerConfig = self.configuration;
    //  服务器 “image_hash”
    __block NSString *imageHash = [self payloadObjectForKey:@"image_hash"];
    
    __weak ANSABTestDesignerConnection *weak_connection = connection;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        __strong ANSABTestDesignerConnection *conn = weak_connection;
        
        ANSABTestDesignerSnapshotResponseMessage *snapshotMessage = [ANSABTestDesignerSnapshotResponseMessage message];
        if ([imageHash isEqualToString:@"BeatHeart"] ||
            conn.appStatus == ANSViewUnload ||
            conn.appStatus == ANSAppInBackground ||
            conn.appStatus == ANSKeyboardShow) {
            ANSDebug(@"仅发送心跳信息");
            [snapshotMessage setPayloadObject:@"200" forKey:@"egMsgCode"];
            snapshotMessage.screenshot = nil;
            [conn sendMessage:snapshotMessage];
            
            return ;
        }
        
        // Update the class descriptions in the connection session if provided as part of the message.
        //  更新本地的服务器 类和枚举信息
        if (serializerConfig) {
            [connection setSessionObject:serializerConfig forKey:ANSSnapshotSerializerConfigKey];
        } else if ([connection sessionObjectForKey:ANSSnapshotSerializerConfigKey]) {
            // Get the class descriptions from the connection session store.
            //   若本地有配置信息，则获取上次保存信息
            serializerConfig = [connection sessionObjectForKey:ANSSnapshotSerializerConfigKey];
        } else {
            // If neither place has a config, this is probably a stale message and we can't create a snapshot.
            return;
        }
        
        //  获取对象标识生成器，用于图层对象唯一标识生成
        ANSObjectIdentityProvider *objectIdentityProvider = [connection sessionObjectForKey:ANSObjectIdentityProviderKey];
        if (objectIdentityProvider == nil) {
            objectIdentityProvider = [[ANSObjectIdentityProvider alloc] init];
            [connection setSessionObject:objectIdentityProvider forKey:ANSObjectIdentityProviderKey];
        }
        
        //  初始化图层结构获取 实例
        ANSApplicationStateSerializer *serializer = [[ANSApplicationStateSerializer alloc]
                                                     initWithApplication:[UIApplication sharedApplication]
                                                     configuration:serializerConfig
                                                     objectIdentityProvider:objectIdentityProvider];
        
        __block UIImage *screenshot = nil;
        __block NSDictionary *serializedObjects = nil;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            screenshot = [serializer screenshotImageForWindowAtIndex:0];
        });
        //  截图处理
        snapshotMessage.screenshot = screenshot;
        
        if ([imageHash isEqualToString:snapshotMessage.imageHash]) {
            ANSDebug(@"页面未改变，保持心跳");
            snapshotMessage.screenshot = nil;
            [snapshotMessage setPayloadObject:@"200" forKey:@"egMsgCode"];
            [conn sendMessage:snapshotMessage];
            return;
        }
        
        [snapshotMessage addExtroResponseInfo];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            //  当前页图层结构
            serializedObjects = [serializer objectHierarchyForWindowAtIndex:0];
        });
        
        snapshotMessage.serializedObjects = serializedObjects;
        
        [conn sendMessage:snapshotMessage];
    }];
    
    return operation;
}


@end
