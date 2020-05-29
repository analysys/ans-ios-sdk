//
//  ANSABTestDesignerConnection.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSABTestDesignerConnection.h"

#import "ANSABTestDesignerDeviceInfoRequestMessage.h"
#import "ANSABTestDesignerSnapshotRequestMessage.h"
#import "ANSABTestDesignerSnapshotResponseMessage.h"
#import "ANSDesignerEventBindingMessage.h"
#import "AnalysysLogger.h"
#import "ANSGzip.h"
#import "ANSUtil.h"

static NSString * const ANSStartLoadingAnimationKey = @"ANSConnectivityBarLoadingAnimation";
static NSString * const ANSFinishLoadingAnimationKey = @"ANSConnectivityBarFinishLoadingAnimation";


@interface ANSABTestDesignerConnection () <ANSWebSocketDelegate>

@property (strong, nonatomic) UIView *connectivityIndicatorWindow;

@end


@implementation ANSABTestDesignerConnection {
    BOOL _open;
    NSURL *_url;
    NSMutableDictionary *_session;
    NSDictionary *_typeToMessageClassMap;
    ANSWebSocket *_webSocket;
    NSOperationQueue *_commandQueue;
    UIView *_recordingView;
    CALayer *_indeterminateLayer;
    void (^_connectCallback)(void);
    void (^_disconnectCallback)(void);
}

- (instancetype)initWithURL:(NSURL *)url
                 keepTrying:(BOOL)keepTrying
            connectCallback:(void (^)(void))connectCallback
         disconnectCallback:(void (^)(void))disconnectCallback {
    self = [super init];
    if (self) {
        
        [self addListeners];
        
        _typeToMessageClassMap = @{
                                   ANSDesignerSnapshotRequestMessageType   : [ANSABTestDesignerSnapshotRequestMessage class],
                                   ANSDesignerDeviceInfoRequestMessageType : [ANSABTestDesignerDeviceInfoRequestMessage class],
                                   ANSDesignerEventBindingRequestMessageType     : [ANSDesignerEventBindingRequestMessage class],
                                   };
        _appStatus = ANSAppStatusOK;
        _open = NO;
        _connected = NO;
        _sessionEnded = NO;
        _session = [NSMutableDictionary dictionary];
        _url = url;
        _connectCallback = connectCallback;
        _disconnectCallback = disconnectCallback;
        
        _commandQueue = [[NSOperationQueue alloc] init];
        _commandQueue.maxConcurrentOperationCount = 1;
        _commandQueue.suspended = YES;
        
        if (keepTrying) {
            [self open:YES maxInterval:20 maxRetries:10];
        } else {
            [self open:YES maxInterval:0 maxRetries:3];
        }
    }
    
    return self;
}

- (void)dealloc {
    _webSocket.delegate = nil;
    [self close];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithURL:(NSURL *)url {
    return [self initWithURL:url keepTrying:NO connectCallback:nil disconnectCallback:nil];
}

/** 尝试 websocket 链接 */
- (void)open:(BOOL)initiate maxInterval:(int)maxInterval maxRetries:(int)maxRetries {
    static int retries = 0;
    BOOL inRetryLoop = retries > 0;
    
    ANSDebug(@"In open. initiate = %d, retries = %d, maxRetries = %d, maxInterval = %d, connected = %d", initiate, retries, maxRetries, maxInterval, _connected);
    
    if (self.sessionEnded || _connected || (inRetryLoop && retries >= maxRetries) ) {
        // break out of retry loop if any of the success conditions are met.
        retries = 0;
    } else if (initiate ^ inRetryLoop) {
        // If we are initiating a new connection, or we are already in a
        // retry loop (but not both). Then open a socket.
        if (!_open) {
            ANSDebug(@"Attempting to open WebSocket to: %@, try %d/%d ", _url, retries, maxRetries);
            _open = YES;
            _webSocket = [[ANSWebSocket alloc] initWithURL:_url];
            _webSocket.delegate = self;
            [_webSocket open];
        }
        if (retries < maxRetries) {
            __weak ANSABTestDesignerConnection *weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MIN(pow(1.4, retries), maxInterval) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                ANSABTestDesignerConnection *strongSelf = weakSelf;
                [strongSelf open:NO maxInterval:maxInterval maxRetries:maxRetries];
            });
            retries++;
        } else {
            [_webSocket close];
        }
    }
}


/**
 关闭长连接
 */
- (void)close {
    [_webSocket close];
    for (id value in _session.allValues) {
        if ([value conformsToProtocol:@protocol(ANSDesignerSessionCollection)]) {
            [value cleanup];
        }
    }
    _session = nil;
}

- (void)setSessionObject:(id)object forKey:(NSString *)key {
    NSParameterAssert(key != nil);
    
    @synchronized (_session) {
        _session[key] = object ?: [NSNull null];
    }
}

- (id)sessionObjectForKey:(NSString *)key {
    NSParameterAssert(key != nil);
    
    @synchronized (_session) {
        id object = _session[key];
        return [object isEqual:[NSNull null]] ? nil : object;
    }
}

/**
 发送websocket消息

 @param message message对象
 */
- (void)sendMessage:(id<ANSABTestDesignerMessage>)message {
    if (_connected) {
        NSString *jsonString = [[NSString alloc] initWithData:[message JSONData] encoding:NSUTF8StringEncoding];
        if ([message.type isEqualToString:@"snapshot_response"]) {
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSData *zipData = [ANSGzip gzipData:jsonData];
            NSString *base64Str = [zipData base64EncodedStringWithOptions:0];
            ANSDebug(@"-------------客户端响应%@数据:%.2f KB 压缩后：%.2f KB-------------\n%@",message.type, jsonString.length/1024.0, base64Str.length/1024.0, jsonString);
            [_webSocket send:base64Str];
        } else {
            ANSDebug(@"-------------客户端响应数据:%.2f KB -------------\n%@\n%@",jsonString.length/1024.0, message.type, jsonString);
            [_webSocket send:jsonString];
        }
    } else {
        ANSDebug(@"Not sending message as we are not connected: %@", [message debugDescription]);
    }
}

/**
 发送可视化回显消息
 
 @param object json字符串
 */
- (void)sendJsonMessage:(id)object {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&parseError];
    if (parseError) {
        ANSDebug(@"eventClickResponse json 转换错误-%@",parseError);
        return;
    }
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [_webSocket send:jsonStr];
}

/**
 解析服务器下发请求，转换为实例对象

 @param message 服务器信息
 @return 实例对象
 */
- (id <ANSABTestDesignerMessage>)designerMessageForMessage:(id)message {
    NSParameterAssert([message isKindOfClass:[NSString class]] || [message isKindOfClass:[NSData class]]);
    
    id <ANSABTestDesignerMessage> designerMessage = nil;
    
    NSData *jsonData = [message isKindOfClass:[NSString class]] ? [(NSString *)message dataUsingEncoding:NSUTF8StringEncoding] : message;
    
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:(NSJSONReadingOptions)0 error:&error];
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *messageDictionary = (NSDictionary *)jsonObject;
        NSString *type = messageDictionary[@"type"];
        NSString *operateType = messageDictionary[@"recordtype"];
        NSDictionary *payload = messageDictionary[@"payload"];
        
        designerMessage = [_typeToMessageClassMap[type] messageWithType:type payload:payload];
        designerMessage.operate = operateType;
    } else {
        ANSBriefWarning(@"Badly formed socket message expected JSON dictionary: %@", error);
    }
    
    return designerMessage;
}

#pragma mark - ANSWebSocketDelegate

/**
 接收到websocket消息

 @param webSocket websocket对象
 @param message 收到消息内容
 */
- (void)webSocket:(ANSWebSocket *)webSocket didReceiveMessage:(id)message {
    if (!_connected) {
        _connected = YES;
        [self showConnectedViewWithLoading:NO];
        if (_connectCallback) {
            _connectCallback();
        }
    }
    id<ANSABTestDesignerMessage> designerMessage = [self designerMessageForMessage:message];
    ANSDebug(@"-------------接收到服务器下发数据:-------------\n%@",message);
    //  对应实例进行消息发送
    NSOperation *commandOperation = [designerMessage responseCommandWithConnection:self];
    
    if (commandOperation) {
        [_commandQueue addOperation:commandOperation];
    }
}

- (void)webSocketDidOpen:(ANSWebSocket *)webSocket {
    ANSDebug(@"WebSocket %@ did open.", webSocket);
    _commandQueue.suspended = NO;
    [self showConnectedViewWithLoading:YES];
}

- (void)webSocket:(ANSWebSocket *)webSocket didFailWithError:(NSError *)error {
    ANSDebug(@"WebSocket did fail with error: %@", error);
    
    [self closeWebSocketConnetion];
}

- (void)webSocket:(ANSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    ANSDebug(@"WebSocket did close with code '%d' reason '%@'.", (int)code, reason);

    [self closeWebSocketConnetion];
}

- (void)closeWebSocketConnetion {
    _commandQueue.suspended = YES;
    [_commandQueue cancelAllOperations];
    [self hideConnectedView];
    _open = NO;
    [_webSocket close];
    if (_connected) {
        _connected = NO;
        if (_disconnectCallback) {
            _disconnectCallback();
        }
    }
}

#pragma mark - 进度条

/**
 显示连接进度条

 @param isLoading 是否正在加载
 */
- (void)showConnectedViewWithLoading:(BOOL)isLoading {
    if (!self.connectivityIndicatorWindow) {
        UIWindow *mainWindow = [[UIApplication sharedApplication] delegate].window;
        self.connectivityIndicatorWindow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainWindow.frame.size.width, 4.f)];
        self.connectivityIndicatorWindow.backgroundColor = [UIColor clearColor];
        self.connectivityIndicatorWindow.alpha = 0;
        self.connectivityIndicatorWindow.hidden = NO;
        
        _recordingView = [[UIView alloc] initWithFrame:self.connectivityIndicatorWindow.frame];
        _recordingView.backgroundColor = [UIColor clearColor];
        _indeterminateLayer = [CALayer layer];
        _indeterminateLayer.backgroundColor = [UIColor colorWithRed:1/255.0 green:179/255.0 blue:109/255.0 alpha:1.0].CGColor;
        _indeterminateLayer.frame = CGRectMake(0, 0, 0, 4.0f);
        [_recordingView.layer addSublayer:_indeterminateLayer];
        [self.connectivityIndicatorWindow addSubview:_recordingView];
        [self.connectivityIndicatorWindow bringSubviewToFront:_recordingView];
        [[UIApplication sharedApplication].keyWindow addSubview:self.connectivityIndicatorWindow];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.connectivityIndicatorWindow.alpha = 1;
        }];
    }
    [self animateConnecting:isLoading];
}

- (void)animateConnecting:(BOOL)isLoading {
    if (isLoading) {
        CABasicAnimation* myAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
        myAnimation.duration = 10.f;
        myAnimation.fromValue = @0;
        myAnimation.toValue = @(_connectivityIndicatorWindow.bounds.size.width * 1.9f);
        myAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        myAnimation.fillMode = kCAFillModeForwards;
        myAnimation.removedOnCompletion = NO;
        [_indeterminateLayer addAnimation:myAnimation forKey:ANSStartLoadingAnimationKey];
    } else {
        [_indeterminateLayer removeAnimationForKey:ANSStartLoadingAnimationKey];
        CABasicAnimation* myAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
        myAnimation.duration = 0.4f;
        myAnimation.fromValue = @([[_indeterminateLayer.presentationLayer valueForKeyPath: @"bounds.size.width"] floatValue]);
        myAnimation.toValue = @(_connectivityIndicatorWindow.bounds.size.width * 2.f);
        myAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        myAnimation.fillMode = kCAFillModeForwards;
        myAnimation.removedOnCompletion = NO;
        [_indeterminateLayer addAnimation:myAnimation forKey:ANSFinishLoadingAnimationKey];
    }
}

- (void)hideConnectedView {
    if (self.connectivityIndicatorWindow) {
        [_indeterminateLayer removeFromSuperlayer];
        [_recordingView removeFromSuperview];
        self.connectivityIndicatorWindow.hidden = YES;
    }
    [self.connectivityIndicatorWindow removeFromSuperview];
    self.connectivityIndicatorWindow = nil;
}

#pragma mark - 添加通知

- (void)addListeners {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillEnterForegroundNotification:)
                               name:UIApplicationWillEnterForegroundNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidEnterBackgroundNotification:)
                               name:UIApplicationDidEnterBackgroundNotification
                             object:nil];
    
    //  添加页面加载状态通知
    [notificationCenter addObserver:self
                           selector:@selector(pageViewUnready:)
                               name:@"AnalysysPageUnready"
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(pageViewReady:)
                               name:@"AnalysysPageReady"
                             object:nil];
    
    [notificationCenter addObserver:self selector:@selector(cleanVisualBindings:) name:@"AnalysysCleanBindings" object:nil];
    
    [notificationCenter addObserver:self selector:@selector(reloadWebVisual) name:@"AnalysysReloadWeb" object:nil];
    
    //  键盘弹出添加监听事件
    [notificationCenter addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardDidHiden:) name:UIKeyboardDidHideNotification object:nil];
}

#pragma mark - 通知回调
/** App进入前台通知 */
- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification {
    _appStatus = ANSAppStatusOK;
}

/** App进入后台通知 */
- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification {
    _appStatus = ANSAppInBackground;
}

/** 页面将要出现或消失状态 */
- (void)pageViewUnready:(NSNotification *)notification {
    _appStatus = ANSViewUnload;
}

/** 页面出现或消失状态 */
- (void)pageViewReady:(NSNotification *)notification {
    _appStatus = ANSAppStatusOK;
}

/** 键盘弹出状态 */
- (void)keyboardDidShow:(NSNotification *)notification {
    _appStatus = ANSKeyboardShow;
}

/** 键盘收回状态 */
- (void)keyboardDidHiden:(NSNotification *)notification {
    _appStatus = ANSAppStatusOK;
}

/** 由可视化状态下断开websocket连接，当App进入前台时，去除原可视化连接中的数据绑定，防止重复绑定 */
- (void)cleanVisualBindings:(NSNotification *)notification {
    ANSEventBindingCollection *bindingCollection = [self sessionObjectForKey:@"event_bindings"];
    if (bindingCollection) {
        [bindingCollection cleanup];
    }
}

/**
 Hybrid可视化。js已返回web图层信息，重新上传当前页面图层结构
 image_hash 任意填，防止与正常相同
 */
- (void)reloadWebVisual {
    NSString *jsonStr = @"{\"type\":\"snapshot_request\",\"payload\":{\"image_hash\":\"SODO\"}}";
    id<ANSABTestDesignerMessage> designerMessage = [self designerMessageForMessage:jsonStr];
    ANSDebug(@"-------------webview 强制图层上传-------------\n");
    NSOperation *commandOperation = [designerMessage responseCommandWithConnection:self];

    if (commandOperation) {
        [_commandQueue addOperation:commandOperation];
    }
}


@end
