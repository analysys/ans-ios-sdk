//
//  EGToastView.m
//  EGAnalyticsDemo
//
//  Created by analysys on 2018/6/1.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "EGToastView.h"

#import "ANSJsonUtil.h"

static const CGFloat lrSpace = 0.0;
static const CGFloat tbSpace = 0.0;

@interface EGToastView()

@property (nonatomic, strong) UIWindow *bgWindow;   //  背景window
@property (nonatomic, strong) UILabel *toastLabel;  //  显示label

@property (nonatomic, assign) CGFloat textHeight;

@end

@implementation EGToastView

+ (instancetype)shareInstance {
    static EGToastView *instance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[EGToastView alloc] init] ;
    });
    return instance;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
    }
    return self;
}

+ (void)showToastWithPara:(NSDictionary *)parameter {
    [[self shareInstance] showToastWithPara:parameter];
}

- (void)showToastWithPara:(NSDictionary *)parameter {
    if (self.bgWindow) {
        [self dismissbgWindowNow];
    }
    
    if (parameter) {
        NSString *textStr = [ANSJsonUtil convertToStringWithObject:parameter];
        if (textStr) {
            [self createPopViewWithText:textStr];
        }
    }
}

- (void)createPopViewWithText:(NSString *)textStr {
    if (![UIApplication sharedApplication].delegate.window) {
        return;
    }
    
    self.bgWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.bgWindow.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.0];
    self.bgWindow.windowLevel = UIWindowLevelStatusBar;
    //  必须先设置个rootVIewController，防止程序重新启动调用时，未设置导致'NSInternalInconsistencyException'闪退
    self.bgWindow.rootViewController = [UIViewController new];
    [self.bgWindow makeKeyAndVisible];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissbgWindow)];
    [self.bgWindow addGestureRecognizer:tap];
    
    
    self.toastLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    //    self.toastLabel.textAlignment = NSTextAlignmentCenter;
//    self.toastLabel.layer.cornerRadius = 8.0;
//    self.toastLabel.layer.masksToBounds = YES;
//    self.toastLabel.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.toastLabel.layer.borderWidth = 5.0;
    CGFloat red = arc4random() % 255/255.0;
    CGFloat green = arc4random() % 255/255.0;
    CGFloat blue = arc4random() % 255/255.0;
    self.toastLabel.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    self.toastLabel.numberOfLines = 0;
    self.toastLabel.textColor = [UIColor whiteColor];
    self.toastLabel.text = textStr;
    CGSize sizeToFit = [self.toastLabel sizeThatFits:CGSizeMake(self.bgWindow.frame.size.width, MAXFLOAT)];
    self.textHeight = sizeToFit.height;
    self.toastLabel.frame = CGRectMake(lrSpace, -self.textHeight, self.bgWindow.frame.size.width-lrSpace*2, self.textHeight);
    [self.bgWindow addSubview:self.toastLabel];
    
    self.toastLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer * toastTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissbgWindowNow)];
    [self.toastLabel addGestureRecognizer:toastTap];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.toastLabel.frame = CGRectMake(lrSpace, tbSpace, [UIScreen mainScreen].bounds.size.width - lrSpace*2, self.textHeight);
    }];
    
}

- (void)dismissbgWindow {
    [UIView animateWithDuration:0.25 animations:^{
        self.toastLabel.frame = CGRectMake(lrSpace, -self.textHeight, [UIScreen mainScreen].bounds.size.width - lrSpace*2, self.textHeight);
        
    } completion:^(BOOL finished) {
        [self dismissbgWindowNow];
    }];
}

- (void)dismissbgWindowNow {
    [self.toastLabel removeFromSuperview];
    self.bgWindow = nil;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
