//
//  ANSVisualSDK.m
//  AnalysysVisual
//
//  Created by SoDo on 2019/2/12.
//  Copyright © 2019 analysys. All rights reserved.
//

#import "ANSVisualSDK.h"

#import "AnalysysSDK.h"
#import "AnalysysAgentConfig.h"

#import "ANSQueue.h"
#import "ANSFileManager.h"
#import "ANSUploadManager.h"
#import "ANSABTestDesignerConnection.h"
#import "ANSEventBinding.h"
#import "AnalysysLogger.h"

#import "ANSSwizzler.h"
#import "ANSTelephonyNetwork.h"
#import "ANSDeviceInfo.h"
#import "ANSReachability.h"
#import "ANSUtil.h"
#import "ANSControllerUtils.h"

#import "ANSConst+private.h"
#import "UIView+ANSHelper.h"

#define AgentLock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER);
#define AgentUnlock() dispatch_semaphore_signal(self->_lock);

//  可视化埋点 默认端口
static NSString *const ANSWebsocketDefaultPort = @"4091";
//  可视化配置 默认端口
static NSString *const ANSVisualConfigDefaultPort = @"4089";

@interface ANSVisualSDK ()

@property (nonatomic, strong) NSSet *eventBindings;
@property (nonatomic, strong) ANSABTestDesignerConnection *designerConnection;
@property (nonatomic, copy) NSString *connectUrl;
@property (nonatomic, copy) NSString *configUrl;

@end

@implementation ANSVisualSDK {
    ANSUploadManager *_uploadManager;
    dispatch_queue_t _networkQueue;
    dispatch_semaphore_t _lock;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedManager {
    static id singleInstance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        if (!singleInstance) {
            singleInstance = [[self alloc] init] ;
        }
    });
    return singleInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
        });
        
        _uploadManager = [[ANSUploadManager alloc] init];
        
        [ANSSwizzler swizzleSelector:@selector(motionBegan:withEvent:) onClass:[UIApplication class] withBlock:^(id view, SEL command, UIEventSubtype motion, UIEvent *event) {
            [self monitorVisualMotionBegan:motion withEvent:event];
        } named:@"ANSVisualMotion"];
        
        [ANSSwizzler swizzleSelector:@selector(sendEvent:) onClass:[UIApplication class] withBlock:^(id view, SEL command, UIEvent *event){
            [self monitoVisualSendEvent:event];
        } named:@"ANSVisualSendEvent" order:AnalysysSwizzleOrderBefore];
        
        _lock = dispatch_semaphore_create(0);
        NSString *netLabel = [NSString stringWithFormat:@"com.analysys.VisualNetworkQueue"];
        _networkQueue = dispatch_queue_create([netLabel UTF8String], DISPATCH_QUEUE_SERIAL);
        
        [self registNotifications];
        
        [self unarchiveEventBindings];
        
        [self executeEventBindings];
    }
    return self;
}

#pragma mark - SDK配置

/** 初始化埋点及下发地址 */
- (void)setVisualBaseUrl:(NSString *)baseUrl {
    if (baseUrl.length == 0) {
        ANSBriefWarning(@"Pleaset set baseURL first.");
        return;
    }
    NSString *serverlUrl = [NSString stringWithFormat:@"wss://%@:%@", baseUrl, ANSWebsocketDefaultPort];
    [self setVisualServerUrl:serverlUrl];
    
    NSString *configUrl = [NSString stringWithFormat:@"https://%@:%@", baseUrl, ANSVisualConfigDefaultPort];
    [self setVisualConfigUrl:configUrl];
}

/** 设置可视化埋点地址 */
- (void)setVisualServerUrl:(NSString *)visualUrl {
    self.connectUrl = @"";
    if (self.designerConnection) {
        [self.designerConnection close];
    }
        
    NSString *url = [ANSUtil getSocketUrlString:visualUrl];
    if (url.length > 0) {
        self.connectUrl = [NSString stringWithFormat:@"%@?appkey=%@&version=%@&os=ios",url, AnalysysConfig.appKey, [ANSDeviceInfo getAppVersion]];
        ANSBriefLog(@"Set visitorDebugURL success. Current visitorDebugURL: %@", url);
    } else {
        ANSBriefWarning(@"visitorDebugURL must start with 'ws://' or 'wss://'.");
    }
}

/** 设置可视化埋点配置下发地址 */
- (void)setVisualConfigUrl:(NSString *)configUrl {
    self.configUrl = @"";
    
    NSString *url = [ANSUtil getHttpUrlString:configUrl];
    if (url.length > 0) {
        self.configUrl = [NSString stringWithFormat:@"%@/configure?appKey=%@&appVersion=%@&lib=iPhone",url, AnalysysConfig.appKey, [ANSDeviceInfo getAppVersion]];
        
        ANSBriefLog(@"Set visitorConfigURL success. Current visitorConfigURL: %@", url);
        
        [ANSQueue dispatchAsyncLogSerialQueueWithBlock:^{
            [self loadServerBindings];
        }];
    } else {
        ANSBriefWarning(@"configURL must start with 'http://' or 'https://'.");
    }
}

#pragma mark - 可视化操作

/// 摇一摇连接可视化
/// @param motion object
/// @param event event
- (void)monitorVisualMotionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventSubtypeMotionShake) {
        [self connectToServer:NO];
    }
}

/** 触发可视化埋点事件 */
- (void)trackObject:(id)trackView withEvent:(NSString *)event {
    ANSDebug(@"----------- 可视化事件：%@ -----------",event);
    [[AnalysysSDK sharedManager] track:event properties:nil];
}

/// 事件点击 获取当前控件文本信息
/// @param event event
- (void)monitoVisualSendEvent:(UIEvent *)event {
    if (event.type == UIEventTypeTouches) {
        UITouch *touch = [event.allTouches anyObject];
        if (touch.view && touch.phase == UITouchPhaseBegan) {
            self.currentPage = NSStringFromClass([ANSControllerUtils currentViewController].class);
            self.controlText = [touch.view ansElementText];
        }
    }
}

#pragma mark - websocket连接

/** 开始长连接 是否重连 */
- (void)connectToServer:(BOOL)reconnect {
    if (self.connectUrl.length == 0) {
        ANSBriefLog(@"Please setVisitorDebugURL first.");
        return;
    }
    
    if ([self.designerConnection isKindOfClass:[ANSABTestDesignerConnection class]] && ((ANSABTestDesignerConnection *)self.designerConnection).connected) {
        ANSDebug(@"websocket connection already exists");
        return;
    }
    
    void (^connectCallback)(void) = ^{
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        //  连接websocket后，停止configure请求的所有binding事件
        for (ANSEventBinding *binding in self.eventBindings) {
            [binding stop];
        }
        
        //  可视化控件点击回显
        void (^block)(id, SEL, id, NSString*) = ^(id obj, SEL sel, id trackView, NSString *event_name) {
            [self echoVisualEvent:event_name view:trackView];
        };
        
        [ANSSwizzler swizzleSelector:@selector(trackObject:withEvent:) onClass:[ANSVisualSDK class] withBlock:block named:@"ANSTrackProperties"];
    };
    
    void (^disconnectCallback)(void) = ^{
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        //  断开websocket连接后不重新绑定控件
        //            for (ANSEventBinding *binding in strongSelf.eventBindings) {
        //                [binding execute];
        //            }
        [ANSSwizzler unswizzleSelector:@selector(trackObject:withEvent:) onClass:[ANSVisualSDK class] named:@"ANSTrackProperties"];
    };
    NSURL *designerURL = [NSURL URLWithString:self.connectUrl];
    self.designerConnection = [[ANSABTestDesignerConnection alloc] initWithURL:designerURL
                                                                    keepTrying:reconnect
                                                               connectCallback:connectCallback
                                                            disconnectCallback:disconnectCallback];
}

/** App端埋点后 点击回显 */
- (void)echoVisualEvent:(NSString *)event view:(id)trackView {
    if ([trackView isKindOfClass:[UIView class]]) {
        UIWindow *window = [ANSUtil currentKeyWindow];
        UIView *view = (UIView *)trackView;
        CGRect position = [view convertRect:view.bounds toView:window];
        if (position.origin.y > window.frame.size.height) {
            position = [view.superview convertRect:view.bounds toView:window];
        }
        [self echoWebVisualEvent:event position:position];
    }
}

/**
 可视化埋点状态下 服务器回显
 
 @param eventName 绑定事件名称
 @param position 控件绝对坐标
 */
- (void)echoWebVisualEvent:(NSString *)eventName position:(CGRect)position {
    if (!self.designerConnection.connected) {
        return;
    }
    NSMutableDictionary *responseInfo = [NSMutableDictionary dictionary];
    responseInfo[@"$event_id"] = eventName;
    responseInfo[@"$app_version"] = [ANSDeviceInfo getAppVersion];
    responseInfo[@"$manufacturer"] = @"Apple";
    responseInfo[@"$model"] = [ANSDeviceInfo getDeviceModel];
    responseInfo[@"$os_version"] = [ANSDeviceInfo getOSVersion];
    responseInfo[@"$lib_version"] = ANSSDKVersion;
    responseInfo[@"$network"] = [[ANSTelephonyNetwork shareInstance] telephonyNetworkDescrition];
    responseInfo[@"$screen_width"] = [NSString stringWithFormat:@"%.0f",[ANSDeviceInfo getScreenWidth]];
    responseInfo[@"$screen_height"] = [NSString stringWithFormat:@"%.0f",[ANSDeviceInfo getScreenHeight]];
    responseInfo[@"$pos_left"] = [NSString stringWithFormat:@"%.1f",position.origin.x];
    responseInfo[@"$pos_top"] = [NSString stringWithFormat:@"%.1f",position.origin.y];
    responseInfo[@"$pos_width"] = [NSString stringWithFormat:@"%.1f",position.size.width];
    responseInfo[@"$pos_height"] = [NSString stringWithFormat:@"%.1f",position.size.height];
    
    [self.designerConnection sendJsonMessage:@{
        @"event_info": responseInfo,
        @"type":@"eventinfo_request",
        @"target_page": self.currentPage ?: @""
    }];
}

#pragma mark - 内部方法

- (void)registNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidBecomeActive:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(reachabilityChangedNotification:)
                               name:ANSNetworkChangedNotification
                             object:nil];
}

/** 解档本地数据 */
- (void)unarchiveEventBindings {
    self.eventBindings = [ANSFileManager unarchiveEventBindings];
}

/** 归档可视化数据 */
- (void)archiveEventBindings {
    [ANSFileManager archiveEventBindings:self.eventBindings];
}

/** 绑定本地可视化数据 */
- (void)executeEventBindings {
    for (id binding in self.eventBindings) {
        if ([binding isKindOfClass:[ANSEventBinding class]]) {
            [binding executeVisualEventBinding];
        }
    }
}

/** 请求服务器绑定事件 */
- (void)loadServerBindings {
    if (self.configUrl.length == 0) {
        ANSBriefWarning(@"Please set configURL");
        return;
    }
    
    if (![[ANSTelephonyNetwork shareInstance] hasNetwork]) {
        ANSBriefWarning(@"Please check the network.");
        return;
    }
    
    if (self.designerConnection.connected) {
        ANSDebug(@"-----------正在进行可视化埋点，不重新获取configure数据-----------");
        return;
    }
    
    dispatch_async(_networkQueue, ^{
        __weak typeof(self) weakSelf = self;
        [self->_uploadManager getRequestWithServerURLStr:self.configUrl parameters:nil success:^(NSURLResponse *response, NSData *responseData) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            NSError *error;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                ANSBriefLog(@"Get visual config failed: %@.", error.description);
                AgentUnlock()
                return;
            }
            
            NSMutableSet *serverEventBindings = [NSMutableSet set];
            id originEventBindings = responseDict[@"data"];
            if (originEventBindings == nil) {
                ANSBriefLog(@"NO visual config data.");
                AgentUnlock()
                return;
            }
            if ([originEventBindings isKindOfClass:[NSArray class]]) {
                ANSBriefLog(@"Get visual config success.");
                ANSDebug(@"Visual config list：\n %@",originEventBindings);
                
                //  停止已绑定事件
                [self.eventBindings makeObjectsPerformSelector:NSSelectorFromString(@"stop")];
                
                //  停止可视化连接中已绑定的控件，防止重复绑定
                //  原因：可视化埋点后（更新等），主动断开websocket，可能修改埋点与已部署埋点控件为同一个
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AnalysysCleanBindings" object:nil];
                for (id obj in originEventBindings) {
                    ANSEventBinding *binding = [ANSEventBinding bindingWithJSONObject:obj];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [binding executeVisualEventBinding];
                    });
                    [serverEventBindings addObject:binding];
                }
            } else {
                ANSBriefLog(@"Get visual config failed: %@.", responseDict);
                AgentUnlock()
                return;
            }
            
            strongSelf.eventBindings = [serverEventBindings copy];
            [strongSelf archiveEventBindings];
            
            AgentUnlock()
        } failure:^(NSError *error) {
            AgentUnlock()
            ANSBriefLog(@"Get visual config failed: %@.", error.description);
        }];
        
        AgentLock()
    });
}

#pragma mark - 通知

/** App前后台切换 */
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:^{
        [self loadServerBindings];
    }];
}

/** 网络变化，防止App首次启动无网未获取数据 */
- (void)reachabilityChangedNotification:(NSNotification *)notification {
    ANSReachability *reachability = notification.object;
    if (self.eventBindings.count == 0 &&
        reachability.networkStatus != ANSNotReachable) {
        [ANSQueue dispatchAsyncLogSerialQueueWithBlock:^{
            [self loadServerBindings];
        }];
    }
}

@end
