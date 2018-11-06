//
//  EGWKWebViewController.m
//  EGAnalyticsDemo
//
//  Created by SoDo on 2018/7/20.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "EGWKWebViewController.h"
#import <WebKit/WebKit.h>
#import <AnalysysAgent/AnalysysAgent.h>

@interface EGWKWebViewController ()<WKNavigationDelegate,WKUIDelegate>

@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) UIProgressView *progressView;  // 进度条

@end

@implementation EGWKWebViewController {
    WKUserContentController* userContentController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.view addSubview:self.webView];
    
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
    //  加载本地文件 带有css、js
    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"app/index.html" withExtension:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:filePath];
    [self.webView loadRequest:request];
    
    
//    if (@available(iOS 11.0, *)) {
//        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    } else {
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
    
    //监听属性
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.view addSubview:self.progressView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    
    [AnalysysAgent resetHybridModel];
    
    //  KVO
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webView removeObserver:self forKeyPath:@"title"];
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        CGRect rectOfStatusbar = [[UIApplication sharedApplication] statusBarFrame];
        CGRect navigationbar = self.navigationController.navigationBar.frame;
        CGRect progressFrame = CGRectMake(0, rectOfStatusbar.size.height + navigationbar.size.height, self.view.bounds.size.width, 2);
        _progressView = [[UIProgressView alloc] initWithFrame:progressFrame];
        _progressView.progressViewStyle = UIProgressViewStyleDefault;
        _progressView.trackTintColor = [UIColor whiteColor]; //  底层颜色
        _progressView.progressTintColor = [UIColor colorWithRed:0 green:151/255.0 blue:224/255.0 alpha:1.0]; //  进度颜色
        _progressView.progress = 0.0;
    }
    return _progressView;
}

#pragma mark *** safearea ***
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


#pragma mark *** KVO ***

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

#pragma mark *** WKNavigationDelegate ***

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"%s",__FUNCTION__);
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"%s",__FUNCTION__);
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"%s",__FUNCTION__);
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"%s",__FUNCTION__);
    self.progressView.hidden = YES;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"%s",__FUNCTION__);
    
    NSLog(@"navigationAction.request.URL->%@",navigationAction.request.URL);
    NSString *urlStr = [navigationAction.request.URL absoluteString];
    if ([AnalysysAgent setHybridModel:webView request:navigationAction.request]) {
        NSLog(@"AnalysysAgent 统计完成");
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
//    [self printUserAgent];
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
//    [self printUserAgent];
    
    completionHandler();
}

- (void)printUserAgent {
    [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString * userAgent, NSError * _Nullable error) {
        NSLog(@"userAgent----%@",userAgent);
    }];
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
