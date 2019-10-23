//
//  UIView+ANSAutoTrack.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/9/27.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "UIView+ANSAutoTrack.h"
#import "UIView+ANSHelper.h"
#import "ANSControllerUtils.h"

#pragma mark - UIView

@implementation UIView (ANSAutoTrack)

- (NSString *)analysysViewId {
    return nil;
}

- (NSString *)analysysViewControllerName {
    UIViewController *currentViewController = [ANSControllerUtils findViewControllerByView:self];
    return NSStringFromClass(currentViewController.class);
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

- (BOOL)analysysElementClickable {
    return NO;
}

- (NSString *)getElementPath {
    if (self == nil) {
        return nil;
    }
    NSMutableArray *pathArray = [NSMutableArray array];
    
    //  1. 末端控件计算
    NSString *tailPath = [self tailPathWithView:self];
    
    //  2. 控件路径计算
    NSArray *viewControllerPath = [self viewControllerPathWithView:self];
    [pathArray addObjectsFromArray:viewControllerPath];
    
    // 3. 倒序“/”分割
    NSArray *resevedArray = [[pathArray reverseObjectEnumerator] allObjects];
    NSString *viewPath = [resevedArray componentsJoinedByString:@"/"];
    NSRange range = [viewPath rangeOfString:@"/"];
    
    // 4. 除去第一个"/"前路径
    if(range.location != NSNotFound) {
        if ([resevedArray.firstObject isEqualToString:@"UIWindow"]) {
            // 顶层为window时无需剔除
            viewPath = [NSString stringWithFormat:@"/%@",[viewPath substringFromIndex:0]];
        } else {
            viewPath = [viewPath substringFromIndex:range.location];
        }
    }
    
    // 路径拼接
    viewPath = [NSString stringWithFormat:@"%@%@", viewPath, tailPath];
    
    return viewPath;
}

/** 当前视图在父视图子视图同类中的排序 */
- (NSString *)locationInSuperViewWithView:(UIView *)view {
    NSString * tailPath = @"";
    NSMutableArray *sameTypeViews = [NSMutableArray array];
    for (UIView *v in view.superview.subviews) {
        if ([v isKindOfClass:[view class]]) {
            [sameTypeViews addObject:v];
        }
    }
    if (sameTypeViews.count == 0) {
        tailPath = @"[0]";
    } else {
        tailPath = [NSString stringWithFormat:@"[%lu]", (unsigned long)[sameTypeViews indexOfObject:view]];
    }
    return tailPath;
}

/**
 末端控件计算
 优先级 tag > eg_varxxx > 父视图的位置
 */
- (NSString *)tailPathWithView:(UIView *)view {
    NSString *tailPath = @"";
    if (view.tag) {
        // 1.1 tag
        tailPath = [NSString stringWithFormat:@"[tag==%ld]", (long)view.tag];
    } else {
        // 1.2 varxxx
        NSString *varA = [view eg_varA];
        NSString *varB = [view eg_varB];
        NSString *varC = [view eg_varC];
        NSString *varD = [view eg_varE];
        if (varA == nil && varB == nil && varC == nil && varD == nil) {
            // 1.3 在父视图所有子视图同类型中的位置
            tailPath = [self locationInSuperViewWithView:view];
        } else {
            NSMutableString *tmpPath = [NSMutableString string];
            varA = varA ? [NSString stringWithFormat:@" AND eg_varA == \\\"%@\\\"", varA] : @"";
            varB = varB ? [NSString stringWithFormat:@" AND eg_varB == \\\"%@\\\"", varB] : @"";
            varC = varC ? [NSString stringWithFormat:@" AND eg_varC == \\\"%@\\\"", varC] : @"";
            varD = varD ? [NSString stringWithFormat:@" AND eg_varE == \\\"%@\\\"", varD] : @"";
            [tmpPath appendString:varA];
            [tmpPath appendString:varB];
            [tmpPath appendString:varC];
            [tmpPath appendString:varD];
            tailPath = [NSString stringWithFormat:@"[(eg_fingerprintVersion >= %@%@)]", @"1", tmpPath];
        }
    }
    return tailPath;
}

/** view和controller 拼接路径 */
- (NSArray *)viewControllerPathWithView:(UIView *)view {
    NSMutableArray *pathArray = [NSMutableArray array];
    //  记录UITableViewCell或UICollectionViewCell
    //    id tableView;
    //    id tableViewCell;
    UIView *tmpView = view;
    while (tmpView) {
        if ([tmpView.nextResponder isKindOfClass:[UIViewController class]]) {
            [pathArray addObject:NSStringFromClass(tmpView.class)];
            
            if ([tmpView.nextResponder isKindOfClass:[UIViewController class]]) {
                // 2.1 controller层级
                UIViewController *controller = (UIViewController *)tmpView.nextResponder;
                [pathArray addObjectsFromArray:[self pathOfController:controller]];
                break;
            }
        } else {
            [pathArray addObject:NSStringFromClass(tmpView.class)];
        }
        
        //  2.2 view 层级
        if (tmpView.superview) {
            tmpView = tmpView.superview;
            
            //            if ([tmpView isKindOfClass:NSClassFromString(@"UICollectionViewCell")] ||
            //                [tmpView isKindOfClass:NSClassFromString(@"UITableViewCell")]) {
            //                tableViewCell = tmpView;
            //            }
            //            if ([tmpView isKindOfClass:NSClassFromString(@"UITableView")] ||
            //                [tmpView isKindOfClass:NSClassFromString(@"UICollectionView")]) {
            //                tableView = tmpView;
            //            }
        } else {
            break;
        }
    }
    //    if (tableViewCell && tableView) {
    //        if ([tableView respondsToSelector:@selector(indexPathForCell:)]) {
    //            NSIndexPath *indexPath = [tableView performSelector:@selector(indexPathForCell:) withObject:tableViewCell];
    //            NSLog(@"indexPath:%@", indexPath);
    //        }
    //    }
    
    return [pathArray copy];
}

/** controller路径计算 */
- (NSArray *)pathOfController:(UIViewController *)viewController {
    NSMutableArray *controllerPathArray = [NSMutableArray array];
    while (viewController) {
        [controllerPathArray addObject:NSStringFromClass(viewController.class)];
        if (viewController.parentViewController) {
            viewController = viewController.parentViewController;
        } else if (viewController.presentingViewController) {
            viewController = viewController.presentingViewController;
        } else {
            break;
        }
    }
    return controllerPathArray;
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
    if ([UIDevice currentDevice].systemVersion.floatValue >= 13.0) {
        return [NSString stringWithFormat:@"%@", self.isOn ? @"off" : @"on"];
    }
    return [NSString stringWithFormat:@"%@", self.isOn ? @"on" : @"off"];
}

@end

@implementation UIStepper (ANSAutoTrack)

- (NSString *)analysysElementContent {
    return [NSString stringWithFormat:@"%.1f", self.value];
}

@end
