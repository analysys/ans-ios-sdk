//
//  UIView+ANSAutoTrack.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/9/27.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "UIView+ANSAutoTrack.h"
#import "ANSControllerUtils.h"
#import "UIView+ANSPathUtils.h"

#pragma mark - UIView

@implementation UIView (ANSAutoTrack)

- (NSString *)analysysViewId {
    return nil;
}

- (NSString *)analysysViewControllerName {
    UIViewController *currentViewController = [ANSControllerUtils findViewControllerByView:self];
    
    return NSStringFromClass(currentViewController.class);
}

- (NSString *)analysysViewControllerTitle {
    UIViewController *currentViewController = [ANSControllerUtils findViewControllerByView:self];
    return [ANSControllerUtils titleFromViewController:currentViewController];
}

- (NSString *)analysysElementType {
//    Class cls = self.class;
//    NSString *clsString = NSStringFromClass(cls);
//    while ([clsString hasPrefix:@"_"]) {
//        cls = cls.superclass;
//        clsString = NSStringFromClass(cls);
//    }
    return NSStringFromClass(self.class);
}

- (NSString *)analysysElementContent {
    //   该判断同可视化中 eg_varE 判断一致
    if ([self isKindOfClass:[NSClassFromString(@"_UIButtonBarButton") class]] ||
        [self isKindOfClass:[NSClassFromString(@"UITabBarButton") class]]) {
        return [ANSControllerUtils contentFromView:self];
    }
    return nil;
}

- (NSString *)analysysElementPath {
    return [self getElementPath];
}

- (NSString *)analysysIndexElementPath {
    return [self getIndexElementPath];
}

- (BOOL)analysysElementClickable {
    return NO;
}

@end

@implementation UILabel (ANSAutoTrack)

- (NSString *)analysysElementContent {
    return self.text.length > 0 ? self.text : nil;
}

@end

@implementation UITextView (ANSAutoTrack)

- (NSString *)analysysElementContent {
    return self.text.length > 0 ? self.text : nil;
}

@end

@implementation UIProgressView (ANSAutoTrack)

- (NSString *)analysysElementContent {
    return [NSString stringWithFormat:@"%.1f", self.progress];
}

@end

@implementation UIImageView (ANSAutoTrack)

@end

@implementation UITabBar (ANSAutoTrack)

- (NSString *)analysysElementContent {
    return self.selectedItem.title.length > 0 ? self.selectedItem.title : nil;
}

@end

@implementation UINavigationBar (ANSAutoTrack)

- (NSString *)analysysElementContent {
    return self.topItem.title.length > 0 ? self.topItem.title : nil;
}

@end

@implementation UISearchBar (ANSAutoTrack)

- (NSString *)analysysElementContent {
    return self.text.length > 0 ? self.text : nil;
}

@end



#pragma mark - UIControl

@implementation UIControl (ANSAutoTrack)

- (BOOL)analysysElementClickable {
    return YES;
}

@end

@implementation UIButton (ANSAutoTrack)

- (NSString *)analysysElementContent {
    return self.titleLabel.text.length > 0 ? self.titleLabel.text : nil;
}

@end

@implementation UIDatePicker (ANSAutoTrack)

- (NSString *)analysysElementContent {
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
    long long dateInterval = [[NSNumber numberWithDouble:nowtime] longLongValue];
    return [NSString stringWithFormat:@"%lld", dateInterval];
}

@end

@implementation UIPageControl (ANSAutoTrack)

- (NSString *)analysysElementContent {
    return [NSString stringWithFormat:@"%ld", (long)self.currentPage];
}

@end

@implementation UISegmentedControl (ANSAutoTrack)

- (NSString *)analysysElementContent {
    return [self titleForSegmentAtIndex:self.selectedSegmentIndex];
}

@end

@implementation UITextField (ANSAutoTrack)

- (NSString *)analysysElementContent {
    return self.text.length > 0 ? self.text : nil;
}

@end

@implementation UISlider (ANSAutoTrack)

- (NSString *)analysysElementContent {
    return [NSString stringWithFormat:@"%.2f", self.value];
}

@end

@implementation UISwitch (ANSAutoTrack)

- (NSString *)analysysElementContent {
//    if ([UIDevice currentDevice].systemVersion.floatValue >= 13.0) {
//        return [NSString stringWithFormat:@"%@", self.isOn ? @"off" : @"on"];
//    }
    return [NSString stringWithFormat:@"%@", self.isOn ? @"on" : @"off"];
}

@end

@implementation UIStepper (ANSAutoTrack)

- (NSString *)analysysElementContent {
    return [NSString stringWithFormat:@"%.1f", self.value];
}

@end

#pragma mark - UITabBarItem
@implementation UITabBarItem (ANSAutoTrack)

- (NSString *)analysysElementContent {
    return self.title;
}

@end

#pragma mark - Cell

@implementation UITableViewCell (AutoTrack)

- (NSString *)analysysElementPosition:(NSIndexPath *)indexPath {
    return [NSString stringWithFormat:@"%ld:%ld",(long)indexPath.section, (long)indexPath.row];
}

@end

@implementation UICollectionViewCell (AutoTrack)

- (NSString *)analysysElementPosition:(NSIndexPath *)indexPath {
    return [NSString stringWithFormat:@"%ld:%ld",(long)indexPath.section, (long)indexPath.row];
}

@end
