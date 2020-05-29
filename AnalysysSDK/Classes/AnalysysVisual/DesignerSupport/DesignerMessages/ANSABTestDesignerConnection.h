//
//  ANSABTestDesignerConnection.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import <Foundation/Foundation.h>
#import "ANSWebSocket.h"

@protocol ANSABTestDesignerMessage;

//  数据上传状态
typedef enum : NSUInteger {
    ANSAppStatusOK, //  正常数据上传
    ANSViewUnload, //  页面未加载完成
    ANSAppInBackground,  //  app退入后台
    ANSKeyboardShow    //  系统键盘弹出
} ANSAppStatus;


@interface ANSABTestDesignerConnection : NSObject

/** 当前App所处的状态(在snapshotRequest中控制是否需要上传数据) */
@property (nonatomic, assign) ANSAppStatus appStatus;
/** 是否已连接websocket */
@property (nonatomic, readonly) BOOL connected;
/** session是否结束(暂未使用) */
@property (nonatomic, assign) BOOL sessionEnded;

- (instancetype)initWithURL:(NSURL *)url;

- (instancetype)initWithURL:(NSURL *)url
                 keepTrying:(BOOL)keepTrying
            connectCallback:(void (^)(void))connectCallback
         disconnectCallback:(void (^)(void))disconnectCallback;

- (void)setSessionObject:(id)object forKey:(NSString *)key;
- (id)sessionObjectForKey:(NSString *)key;

/**
 发送websocket信息

 @param message 消息对象
 */
- (void)sendMessage:(id<ANSABTestDesignerMessage>)message;

/**
 发送可视化回显消息

 @param object json字符串
 */
- (void)sendJsonMessage:(id)object;

/**
 关闭websocket
 */
- (void)close;


@end
