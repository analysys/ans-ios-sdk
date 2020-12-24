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
- (IBAction)aClick:(id)sender;
- (IBAction)bClick:(id)sender;

@end

@implementation ANSWKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent = NO;
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:self.configuration];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.view addSubview:self.webView];
    
//    NSURL *filePath = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.5.128/openSource-JS/demo/ios.html?t=%f",[[NSDate date] timeIntervalSince1970]]];
    NSURL *filePath = [NSURL URLWithString:[NSString stringWithFormat:@"https://uc.analysys.cn/huaxiang/web_visual/index.html?t=%f",[[NSDate date] timeIntervalSince1970]]];
    
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
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0,[UIScreen mainScreen].bounds.size.height - 200, [UIScreen mainScreen].bounds.size.width/2, 60);
    [btn setTitle:@"hello" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor greenColor]];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height - 200, [UIScreen mainScreen].bounds.size.width/2, 60);
    [btn1 setTitle:@"no-hello" forState:UIControlStateNormal];
    [btn1 setBackgroundColor:[UIColor redColor]];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(btnClick1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
}

- (void)btnClick {
    
}

- (void)btnClick1 {
    
}

- (WKWebViewConfiguration *)configuration {
    if (!_configuration) {
        _configuration = [[WKWebViewConfiguration alloc] init];
        [AnalysysAgent setAnalysysAgentHybrid:_configuration scriptMessageHandler:self];
    }
    return _configuration;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    
    [AnalysysAgent resetHybridModel];
    [AnalysysAgent resetAnalysysAgentHybrid:self.configuration];
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
    [AnalysysAgent setAnalysysAgentHybridScriptMessage:message];
}

#pragma mark - WKNavigationDelegate

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
//    [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString * userAgent, NSError * _Nullable error) {
//        NSLog(@"1 =======%@",userAgent);
//    }];
    
    NSLog(@"URLString = %@",navigationAction.request.URL);
//    NSString *str = [NSString stringWithFormat:@"%@",navigationAction.request.URL];
    
    if ([AnalysysAgent setHybridModel:webView request:navigationAction.request]) {

        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
        
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 显示一个按钮。点击后调用completionHandler回调
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        completionHandler();
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 显示两个按钮，通过completionHandler回调判断用户点击的确定还是取消按钮
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler(NO);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

// 显示一个带有输入框和一个确定按钮的，通过completionHandler回调用户输入的内容
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//
//    }];
//    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//        completionHandler(alertController.textFields.lastObject.text);
//    }]];
//    [self presentViewController:alertController animated:YES completion:nil];
    NSLog(@"prompt = %@, defaultText = %@",prompt, defaultText);
    
    completionHandler(@"aaaa");
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

- (IBAction)aClick:(id)sender {
}

- (IBAction)bClick:(id)sender {
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
