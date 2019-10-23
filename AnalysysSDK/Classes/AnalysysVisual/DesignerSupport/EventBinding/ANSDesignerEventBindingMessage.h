//
//  ANSDesignerEventBindingMessage.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSAbstractABTestDesignerMessage.h"
#import "ANSDesignerSessionCollection.h"

extern NSString *const ANSDesignerEventBindingRequestMessageType;

/**
 * @class
 * @abstract 处理服务器下发数据
 *
 * @description 将下发埋点数据转换为 ANSEventBinding 数据对象并分类保存处理
 */

@interface ANSEventBindingCollection : NSObject<ANSDesignerSessionCollection>

//  所有埋点数据
@property (nonatomic, strong) NSMutableArray *allBindings;

@end



/**
 * @class
 * @abstract 接收服务器下发埋点信息
 *
 * @description 处理服务器 “event_binding_request”
 */


@interface ANSDesignerEventBindingRequestMessage : ANSAbstractABTestDesignerMessage

@end



/**
 * @class
 * @abstract 响应服务器模型
 *
 * @description 响应服务器 “event_binding_response”
 */


@interface ANSDesignerEventBindingResponseMessage : ANSAbstractABTestDesignerMessage

+ (instancetype)message;

@property (nonatomic, copy) NSString *status;

@end


/**
 * @class
 * @abstract 响应服务器器 track_message
 *
 * @description 暂未使用
 */


@interface ANSDesignerTrackMessage : ANSAbstractABTestDesignerMessage

+ (instancetype)message;
+ (instancetype)messageWithPayload:(NSDictionary *)payload;

@end
