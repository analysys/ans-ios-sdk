//
//  AnalysysLogManager.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/27.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "AnalysysLogManager.h"
#import "AnalysysLogVC.h"

@interface AnalysysLogManager()

@end
@implementation AnalysysLogManager

+ (instancetype)sharedSingleton {
    static AnalysysLogManager *_singleTon = nil;
    static dispatch_once_t onceTask;
    dispatch_once(&onceTask, ^{
        _singleTon = [[AnalysysLogManager alloc] init];
    });
    return _singleTon;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)createSuspendButton
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"日志" forState:UIControlStateNormal];
    btn.bounds = CGRectMake(0, 0, 60, 60);
    btn.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    btn.backgroundColor = [UIColor colorWithHexString:@"#20a0ff"];
    [btn addTarget:self action:@selector(showLogVC) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 30.0;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [btn addGestureRecognizer:pan];
    
    [[UIApplication sharedApplication].keyWindow addSubview:btn];
    self.button = btn;
}

- (void)showLogVC
{
    AnalysysLogVC *analysysLogVC = [[AnalysysLogVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:analysysLogVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [[self ans_findVisibleViewController] presentViewController:nav animated:true completion:^{
        
        self.button.enabled = NO;
        
    }];
}

- (void)pan:(UIPanGestureRecognizer *)pan
{
    //获取偏移量
    // 返回的是相对于最原始的手指的偏移量
    CGPoint transP = [pan translationInView:self.button];

    // 移动图片控件
    self.button.transform = CGAffineTransformTranslate(self.button.transform, transP.x, transP.y);

    // 复位,表示相对上一次
    [pan setTranslation:CGPointZero inView:self.button];
}

- (void)onEventDataReceived:(id)eventData {
    if (eventData) {
        [[AnalysysLogData sharedSingleton].logData insertObject:eventData atIndex:0];
    }
}

- (UIViewController *)ans_rootViewController{

    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    NSAssert(window, @"The window is empty");
    return window.rootViewController;
}

- (UIViewController *)ans_findVisibleViewController {
    UIViewController* currentViewController = [self ans_rootViewController];
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        } else {
            if ([currentViewController isKindOfClass:[UINavigationController class]]) {
                currentViewController = ((UINavigationController *)currentViewController).visibleViewController;
            } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
                currentViewController = ((UITabBarController* )currentViewController).selectedViewController;
            } else {
                break;
            }
        }
    }
    return currentViewController;
}


@end
