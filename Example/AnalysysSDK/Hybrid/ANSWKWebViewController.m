//
//  ANSWKWebViewController.m
//  EGAnalyticsDemo
//
//  Created by SoDo on 2018/7/20.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "ANSWKWebViewController.h"

//  判断是否引入某个类库
#if __has_include(<WebKit/WebKit.h>)
#import <WebKit/WebKit.h>
#else

#endif
#import <JavaScriptCore/JavaScriptCore.h>

#import <AnalysysSDK/AnalysysAgent.h>


@interface WeakScriptMessageDelegate : NSObject

@property (nonatomic, weak) id scriptDelegate;

- (instancetype)initWithDelegate:(id)scriptDelegate;

@end

@implementation WeakScriptMessageDelegate

- (instancetype)initWithDelegate:(id)scriptDelegate {
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end

@interface ANSWKWebViewController ()<WKNavigationDelegate,WKUIDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebViewConfiguration *configuration;
@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) UIProgressView *progressView;  // 进度条
//@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (nonatomic, strong) UIBarButtonItem *backItem;
@property (nonatomic, strong) UIBarButtonItem *closeItem;

@end

@implementation ANSWKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    self.navigationController.navigationBar.translucent = NO;
    
//    [self.navigationItem setLeftBarButtonItem:self.closeItem];
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:self.configuration];
//    NSLog(@"webview 地址：%@",self.webView);
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    WKUserContentController *userContent = self.configuration.userContentController;
    [userContent addScriptMessageHandler:[[WeakScriptMessageDelegate alloc] initWithDelegate:self] name:@"Native"];
    [self.view addSubview:self.webView];
    
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    
//    self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.btn.frame = CGRectMake(0,0, 100, 60);
//    [self.btn setTitle:@"hello" forState:UIControlStateNormal];
//    [self.btn setBackgroundColor:[UIColor magentaColor]];
//    [self.btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.view addSubview:self.btn];
    
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
    //  加载本地文件 带有css、js
//    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"app/index.html" withExtension:nil];
    NSURL *filePath = [NSURL URLWithString:@"http://uc.analysys.cn/huaxiang/cqqtest/index.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:filePath];
    [self.webView loadRequest:request];
    
    
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //监听属性
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.view addSubview:self.progressView];
    
    
//    [self.webView evaluateJavaScript:@"" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//
//    }];
}

- (WKWebViewConfiguration *)configuration {
    if (!_configuration) {
        _configuration = [[WKWebViewConfiguration alloc] init];
    }
    return _configuration;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    
    [AnalysysAgent resetHybridModel];
    
    [self.configuration.userContentController removeScriptMessageHandlerForName:@"Native"];
    
    //  KVO
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webView removeObserver:self forKeyPath:@"title"];
}

- (UIProgressView *)progressView {
    if (!_progressView) {
//        CGRect rectOfStatusbar = [[UIApplication sharedApplication] statusBarFrame];
//        CGRect navigationbar = self.navigationController.navigationBar.frame;
//        CGRect progressFrame = CGRectMake(0, rectOfStatusbar.size.height + navigationbar.size.height, self.view.bounds.size.width, 2);
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 2)];
        _progressView.progressViewStyle = UIProgressViewStyleDefault;
        _progressView.trackTintColor = [UIColor whiteColor]; //  底层颜色
        _progressView.progressTintColor = [UIColor colorWithRed:0 green:151/255.0 blue:224/255.0 alpha:1.0]; //  进度颜色
        _progressView.progress = 0.0;
    }
    return _progressView;
}

#pragma mark - safearea
- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    
    [self updateOrientation];
}

- (void)updateOrientation {
    if (@available(iOS 11.0, *)) {
        CGRect frame = self.webView.frame;
        frame.origin.x = self.view.safeAreaInsets.left;
        frame.size.width = self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right;
        frame.size.height = self.view.frame.size.height - self.view.safeAreaInsets.bottom;
        self.webView.frame = frame;
    } else {
        // Fallback on earlier versions
    }
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"title"]) {
        self.title = self.webView.title;
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
//        NSLog(@"webView progress: %f", self.webView.estimatedProgress);
        self.progressView.progress = self.webView.estimatedProgress;
        if (self.webView.estimatedProgress >= 1.0) {
            self.progressView.hidden = YES;
        }
    }
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"console.log----%@", message);
}

#pragma mark - WKNavigationDelegate

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"%s",__FUNCTION__);
}

// 当内容开始返回时调用
//- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
//    NSLog(@"%s",__FUNCTION__);
//    UIBarButtonItem *backItem = self.navigationItem.leftBarButtonItems.firstObject;
//    if (backItem) {
//        if ([self.webView canGoBack]) {
//            [self.navigationItem setLeftBarButtonItems:@[self.backItem, self.closeItem]];
//        } else {
//            [self.navigationItem setLeftBarButtonItems:@[self.closeItem]];
//        }
//    }
//}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"%s",__FUNCTION__);
    
    
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    CGRect absoluteRect = [self.webView convertRect:self.webView.bounds toView:window];
    NSLog(@"absoluteRect:%@",NSStringFromCGRect(absoluteRect));
    
//    3.
//    SEL isLoadingSel = NSSelectorFromString(@"isLoading");
//    if (isLoadingSel) {
//        IMP loadingImp = [webView methodForSelector:isLoadingSel];
//        BOOL (*func)(id, SEL) = (BOOL (*)(id, SEL))loadingImp;
//        BOOL result =func(webView, isLoadingSel);
//        NSLog(@"页面加载结果didFinishNavigation-%d",result);
//    }
    
//    2.
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    NSLog(@"---------------------- 1 ----------------------");
//    [self.webView evaluateJavaScript:@"a('')" completionHandler:^(NSString * userAgent, NSError * _Nullable error) {
//        NSLog(@"userAgent----%@",userAgent);
//        NSLog(@"---------------------- 2 ----------------------");
//        dispatch_semaphore_signal(semaphore);
//    }];
//    NSLog(@"---------------------- 3 ----------------------");
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
//    4.
//    SEL evaluateSelector = NSSelectorFromString(@"evaluateJavaScript:completionHandler:");
//    if (evaluateSelector) {
//
//        typedef void(^CompletionBlock)(id, NSError *);
//        CompletionBlock completionHandler = ^(id response, NSError *error) {
//            NSLog(@"WKWebView 回调结果:%@ error:%@", response, error.description);
//
//            if (error) {
//                return ;
//            }
//
//        };
//        IMP evaluateImp = [webView methodForSelector:evaluateSelector];
//        void *(*func)(id, SEL, NSString *, CompletionBlock) = (void *(*)(id, SEL, NSString *, CompletionBlock))evaluateImp;
//        func(webView, evaluateSelector, @"a('')", completionHandler);
//
//    }
    
//    1.
//    NSString *dom = @"document.documentElement.innerHTML";
    [webView evaluateJavaScript:@"a('')" completionHandler:^(NSString * html, NSError * _Nullable error) {
        NSLog(@"html----%@",html);
    }];
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"%s",__FUNCTION__);
    self.progressView.hidden = YES;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
//    [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString * userAgent, NSError * _Nullable error) {
//        NSLog(@"1 =======%@",userAgent);
//    }];
    
    if ([AnalysysAgent setHybridModel:webView request:navigationAction.request]) {
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
        
    decisionHandler(WKNavigationActionPolicyAllow);
}

-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
//    [self printUserAgent];
    NSLog(@"webAlert:%@",message);
    
    completionHandler();
}

- (void)printUserAgent {
    [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString * userAgent, NSError * _Nullable error) {
        NSLog(@"userAgent----%@",userAgent);
        if ([userAgent containsString:@"BOE123"]) {
            return ;
        }
        NSString *defaultUserAgent = userAgent;
        NSString *BOEUserAgent = @"BOE123"; //  自定义追加参数
        NSString *allUserAgent = [NSString stringWithFormat:@"%@ %@",defaultUserAgent, BOEUserAgent];
        [self.webView setCustomUserAgent:allUserAgent];
        
        [self printUserAgent];
    }];
}

- (UIBarButtonItem *)backItem {
    if (!_backItem) {
        _backItem = [[UIBarButtonItem alloc] initWithTitle:@"上一页" style:UIBarButtonItemStylePlain target:self action:@selector(backItemDidClicked)];
    }
    return _backItem;
}

- (void)backItemDidClicked {
    [self.webView goBack];
}


- (UIBarButtonItem *)closeItem {
    if (!_closeItem) {
        _closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeItemDidClicked)];
    }
    return _closeItem;
}

- (void)closeItemDidClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
