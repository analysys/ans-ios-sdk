//
//  ANSDesignerEventBindingRequestMesssage.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSDesignerEventBindingMessage.h"

#import "ANSABTestDesignerConnection.h"
#import "ANSEventBinding.h"
#import "AnalysysLogger.h"

NSString *const ANSDesignerEventBindingRequestMessageType = @"event_binding_request";

NSString *const Binding_All = @"all";
NSString *const Binding_Save = @"save";
NSString *const Binding_Update = @"update";
NSString *const Binding_Delete = @"delete";

@implementation ANSEventBindingCollection {
    NSMutableArray *_singleBatchBindings;   //  单次批量埋点（因服务器首次连接下发为：分批多次下发）
    NSMutableArray *_addBindings;   //  本次新增的埋点
    NSMutableArray *_updateBindings;   //  本次修改的埋点
    NSMutableArray *_deleteBindings;   //  本次删除的埋点
}

/** 初始化数组 */
- (void)setUpDataArray {
    if (!self.allBindings) {
        self.allBindings = [NSMutableArray array];
    }
    _singleBatchBindings = [NSMutableArray array];
    _addBindings = [NSMutableArray array];
    _updateBindings = [NSMutableArray array];
    _deleteBindings = [NSMutableArray array];
}

/**
 根据服务器下发埋点信息，进行控件绑定

 @param bindingPayload 埋点数据
 @param operate 操作类型，all/save/update/delete
 */
- (void)updateBindings:(NSArray *)bindingPayload operate:(NSString *)operate {
    //  重置数组
    [self setUpDataArray];
    
    //  4.0.6及之后版本
    if (operate.length > 0) {
        [self batchBindingPayload:bindingPayload operate:operate];
    } else {
        //  兼容4.0.5及之前版本
        [self allBindingPayload:bindingPayload];
    }
    ANSDebug(@"WebSocket Binding. OperateType: %@ \n %@",operate, bindingPayload);
}

#pragma mark - 服务器数据下发处理

/**
 4.0.5及之前版本
 首次连接、新增、删除、修改 后全量下发埋点信息

 @param bindingPayload 服务器下发埋点数据
 */
- (void)allBindingPayload:(NSArray *)bindingPayload {
    NSMutableArray *newBindings = [NSMutableArray array];
    for (NSDictionary *bindingInfo in bindingPayload) {
        ANSEventBinding *binding = [ANSEventBinding bindingWithJSONObject:bindingInfo];
        if (binding) {
            [newBindings addObject:binding];
        }
    }
    //  清理原有控件绑定事件
    for (ANSEventBinding *oldBinding in self.allBindings) {
        [oldBinding stop];
    }
    self.allBindings = newBindings;
    //  重新绑定所有埋点控件
    for (ANSEventBinding *newBinding in self.allBindings) {
        [newBinding executeVisualEventBinding];
    }
}

/**
 4.0.6及之后版本
 批量下发所有埋点、新增、删除和修改埋点

 @param bindingPayload 服务器下发埋点数据
 */
- (void)batchBindingPayload:(NSArray *)bindingPayload operate:(NSString *)operate {
    for (NSDictionary *bindingInfo in bindingPayload) {
        ANSEventBinding *binding = [ANSEventBinding bindingWithJSONObject:bindingInfo];
        if (binding) {
            [self singleBinding:binding withOperate:operate];
        }
    }
}

/**
 处理单条埋点数据

 @param binding 埋点数据
 */
- (void)singleBinding:(ANSEventBinding *)binding withOperate:(NSString *)operate {
    if ([operate isEqualToString:Binding_All]) {
        [self receivedAllTypeBinding:binding];
    } else if ([operate isEqualToString:Binding_Save]) {
        [self receivedSaveTypeBinding:binding];
    } else if ([operate isEqualToString:Binding_Update]) {
        [self receivedUpdateTypeBinding:binding];
    } else if ([operate isEqualToString:Binding_Delete]) {
        [self receivedDeleteTypeBinding:binding];
    } else {
        ANSDebug(@"可视化operate类型错误:%@",operate);
    }
}


/**
 处理连接websocket后下发的所有埋点数据
 operate - all

 @param binding 埋点对象
 */
- (void)receivedAllTypeBinding:(ANSEventBinding *)binding {
    ANSDebug(@"-------- all埋点：%@ --------",binding.eventName);
    //  控件绑定
    [binding executeVisualEventBinding];

    [self.allBindings addObject:binding];
    
    [_singleBatchBindings addObject:binding];
}

/**
 处理新增埋点数据
 operate - save
 
 @param binding 埋点对象
 */
- (void)receivedSaveTypeBinding:(ANSEventBinding *)binding {
    ANSDebug(@"-------- save埋点：%@ --------",binding.eventName);
    
    //  控件绑定
    [binding executeVisualEventBinding];
    
    [self.allBindings addObject:binding];
    
    [_addBindings addObject:binding];
}

/**
 处理新增埋点数据
 operate - update
 
 @param binding 埋点对象
 */
- (void)receivedUpdateTypeBinding:(ANSEventBinding *)binding {
//    ANSDebug(@"-------- 修改埋点：%@ --------",binding.eventName);
    //  ① 注意 localBinding 和 binding 的操作
    //  ② 由于需要替换数组内数据，使用 NSEnumerator 迭代器
    NSEnumerator *enumerator = [self.allBindings reverseObjectEnumerator];
    ANSEventBinding *localBinding = nil;
    while (localBinding = [enumerator nextObject]) {
        if ([binding.path.pathString isEqualToString:localBinding.path.pathString]) {
            NSInteger index = [self.allBindings indexOfObject:localBinding];
            if (index != NSNotFound) {
                ANSDebug(@"-------- update埋点：%@ --------",binding.eventName);
                [localBinding stop];
                [binding executeVisualEventBinding];
                
                [self.allBindings replaceObjectAtIndex:index withObject:binding];
                
                [_updateBindings addObject:binding];
            }
        }
    }
}

/**
 处理新增埋点数据
 operate - delete
 
 @param binding 埋点对象
 */
- (void)receivedDeleteTypeBinding:(ANSEventBinding *)binding {
//    ANSDebug(@"-------- 删除埋点：%@ --------",binding.eventName);
    NSEnumerator *enumerator = [self.allBindings reverseObjectEnumerator];
    ANSEventBinding *localBinding = nil;
    while (localBinding = [enumerator nextObject]) {
        if ([binding.path.pathString isEqualToString:localBinding.path.pathString]) {
            ANSDebug(@"-------- delete埋点：%@ --------",binding.eventName);
            [localBinding stop];
            [self.allBindings removeObject:localBinding];
            
            [_deleteBindings addObject:binding];
        }
    }
}


/**
 清理控件绑定信息
 */
- (void)cleanup {
    for (ANSEventBinding *oldBinding in self.allBindings) {
        [oldBinding stop];
    }
    self.allBindings = nil;
}

@end

@implementation ANSDesignerEventBindingRequestMessage

+ (instancetype)message {
    return [(ANSDesignerEventBindingRequestMessage *)[self alloc] initWithType:@"event_binding_request"];
}

- (NSOperation *)responseCommandWithConnection:(ANSABTestDesignerConnection *)connection {
    __weak ANSABTestDesignerConnection *weak_connection = connection;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        ANSABTestDesignerConnection *conn = weak_connection;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSArray *payload = [self payload][@"events"];
            ANSEventBindingCollection *bindingCollection = [conn sessionObjectForKey:@"event_bindings"];
            if (!bindingCollection) {
                bindingCollection = [[ANSEventBindingCollection alloc] init];
                [conn setSessionObject:bindingCollection forKey:@"event_bindings"];
            }
            [bindingCollection updateBindings:payload operate:self.operate];
        });
        
        ANSDesignerEventBindingResponseMessage *changeResponseMessage = [ANSDesignerEventBindingResponseMessage message];
        changeResponseMessage.status = @"OK";
        [conn sendMessage:changeResponseMessage];
    }];
    
    return operation;
}

@end


