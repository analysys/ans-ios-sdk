//
//  UIScrollView+ANSSwizzling.m
//  AnalysysAgent
//
//  Created by SoDo on 2018/6/30.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import "UIScrollView+ANSSwizzling.h"
#import "NSObject+ANSSwizzling.h"

@implementation UIScrollView (ANSSwizzling)

//+(void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        //  // 在 load 中 hook UIScrollView 的 setDelegate 方法
//        [NSObject hook_exchangeMethod:[UIScrollView class] originalSel:@selector(setDelegate:) replacedClass:[self class] replacedSel:@selector(ans_scroll_setDelegate:)];
//    });
//}

- (void)ans_scroll_setDelegate:(id)delegate {
    [self ans_scroll_setDelegate:delegate];
    // 获取delegate实际的类
    Class sClass = [delegate class];
    if (sClass) {
        //  交换相应的delegate方法，相应实例中必须实现需要交换的方法，否则不会生效
        [UIScrollView AnsExchangeOriginalSel:@selector(scrollViewDidScroll:)
                             replacedSel:@selector(ans_scrollViewDidScroll:)];
        
        [UIScrollView AnsExchangeOriginalSel:@selector(scrollViewDidEndDecelerating:)
                             replacedSel:@selector(ans_scrollViewDidEndDecelerating:)];

        [UIScrollView AnsExchangeOriginalSel:@selector(scrollViewDidScrollToTop:)
                               replacedSel:@selector(ans_scrollViewDidScrollToTop:)];
        
        [UIScrollView AnsExchangeOriginalSel:@selector(scrollViewDidEndDragging:willDecelerate:)
                               replacedSel:@selector(ans_scrollViewDidEndDragging:willDecelerate:)];
    }
}

- (void)ans_scrollViewDidScroll:(UIScrollView *)scrollView {
    [self ans_scrollViewDidScroll:scrollView];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AnalysysPageUnready" object:nil];
}

- (void)ans_scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self ans_scrollViewDidEndDecelerating:scrollView];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AnalysysPageReady" object:nil];
}

- (void)ans_scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AnalysysPageReady" object:nil];
}

- (void)ans_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AnalysysPageReady" object:nil];
}

@end
