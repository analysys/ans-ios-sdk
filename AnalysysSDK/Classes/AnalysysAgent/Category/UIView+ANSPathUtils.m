//
//  UIView+ANSPathUtils.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/11/19.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "UIView+ANSPathUtils.h"

#import "UIView+ANSHelper.h"
#import "ANSControllerUtils.h"

static NSString *pathLeft = @"["; // 路径子视图排序左侧标识
static NSString *pathRight = @"]"; // 路径子视图排序右侧标识

@implementation UIView (ANSPathUtils)

- (NSString *)getElementPath {
    return [self getIndexElementIgnoreTail:NO];
}

- (NSString *)getIndexElementPath {
    return [self getIndexElementIgnoreTail:YES];
}

- (NSString *)getIndexElementIgnoreTail:(BOOL)ignoreTailPath {
    
    //  1. 末端控件计算
    NSString *tailPath;
    if (!ignoreTailPath) {
        tailPath = [self tailPathWithView:self isMemberType:YES];
    }
    
    //  2. view路径
    NSMutableArray *views = [NSMutableArray arrayWithArray:[self getViewPathWithView:self]];
    NSArray *viewsPath = [self getClassIndexStringWithObjectArray:views];
    
    //  3. 控制器路径
    NSArray *viewContrllers = [self getViewControllerPathWithView:views.lastObject];
    NSArray *controllersPath = [self getClasssStringWithObjectArray:viewContrllers];
    
    //  4. 拼接view及控制器路径
    NSMutableArray *viewFullPath = [NSMutableArray arrayWithArray:viewsPath];
    [viewFullPath addObjectsFromArray:controllersPath];
    NSString *fullPath = [self generatePathWithPathArray:viewFullPath];
    
    //  5. 移除末尾多余[xxx]
    if (tailPath) {
        NSRange range = [fullPath rangeOfString:pathLeft options:NSBackwardsSearch];
        if(range.location != NSNotFound) {
            fullPath = [fullPath substringToIndex:range.location];
        }
        //  6. 路径拼接
        fullPath = [NSString stringWithFormat:@"%@%@", fullPath, tailPath];
    }
    
    return fullPath;
}

#pragma mark - private

/** 将对象数据转为类字符串数据 */
- (NSArray *)getClasssStringWithObjectArray:(NSArray *)objectArray {
    NSMutableArray *stringClasses = [NSMutableArray array];
    for (NSObject *object in objectArray) {
        [stringClasses addObject:NSStringFromClass(object.class)];
    }
    return stringClasses;
}

/** 生成路径信息 */
- (NSString *)generatePathWithPathArray:(NSArray *)pathArray {
    // 1. 倒序“/”分割
    NSArray *resevedArray = [[pathArray reverseObjectEnumerator] allObjects];
    NSString *viewPath = [resevedArray componentsJoinedByString:@"/"];
    NSRange range = [viewPath rangeOfString:@"/"];
    
    // 2. 除去第一个"/"前路径
    if(range.location != NSNotFound) {
        if ([resevedArray.firstObject isEqualToString:@"UIWindow"]) {
            // 顶层为window时无需剔除
            viewPath = [NSString stringWithFormat:@"/%@",[viewPath substringFromIndex:0]];
        } else {
            viewPath = [viewPath substringFromIndex:range.location];
        }
    }
    return viewPath;
}

/**
 末端控件计算
 优先级 tag > eg_varxxx > 父视图的位置
 */
- (NSString *)tailPathWithView:(UIView *)view isMemberType:(BOOL)isMemberType {
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
            tailPath = [self locationInSuperViewWithView:view isMemberType:isMemberType];
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

/** 当前视图在父视图子视图同类中的排序 */
- (NSString *)locationInSuperViewWithView:(UIView *)view isMemberType:(BOOL)isMemberType {
    NSString * tailPath = @"";
    NSMutableArray *sameTypeViews = [NSMutableArray array];
    for (UIView *v in view.superview.subviews) {
        if (isMemberType) {
            if ([v isMemberOfClass:[view class]]) {
                [sameTypeViews addObject:v];
            }
        } else {
            if ([v isKindOfClass:[view class]]) {
                [sameTypeViews addObject:v];
            }
        }
    }
    if (sameTypeViews.count == 0) {
        tailPath = @"[0]";
    } else {
        tailPath = [NSString stringWithFormat:@"[%lu]", (unsigned long)[sameTypeViews indexOfObject:view]];
    }
    return tailPath;
}

/** view对象栈 */
- (NSArray *)getViewPathWithView:(UIView *)view {
    NSMutableArray *viewPathArray = [NSMutableArray array];
    UIView *tmpView = view;
    while (tmpView) {
        if (![tmpView.nextResponder isKindOfClass:[UIViewController class]]) {
            [viewPathArray addObject:tmpView];
        } else {
            UIViewController *controller = (UIViewController *)tmpView.nextResponder;
            NSArray *controllers = [ANSControllerUtils allShowViewControllers];
            //NSLog(@"allControllers:\n%@", controllers);
            //  防止某些父vc直接将子vc.view添加至视图，导致与服务器路径不一致
            if (![controllers containsObject:controller]) {
                if (tmpView.superview) {
                    [viewPathArray addObject:tmpView];
                    tmpView = tmpView.superview;
                    continue;
                } else {
                    [viewPathArray addObject:tmpView];
                    break;
                }
            } else {
                [viewPathArray addObject:tmpView];
                break;
            }
        }
        if (tmpView.superview) {
            tmpView = tmpView.superview;
        } else {
            break;
        }
    }
    
    return [viewPathArray copy];
}

/** controller对象栈 */
- (NSArray *)getViewControllerPathWithView:(UIView *)view {
    NSMutableArray *controllerPathArray = [NSMutableArray array];
    if ([view.nextResponder isKindOfClass:[UIViewController class]]) {
        UIViewController *viewController = (UIViewController *)view.nextResponder;
        while (viewController) {
            [controllerPathArray addObject:viewController];
            if (viewController.parentViewController) {
                viewController = viewController.parentViewController;
            } else if (viewController.presentingViewController) {
                viewController = viewController.presentingViewController;
            } else {
                break;
            }
        }
    }
    return [controllerPathArray copy];
}

/** 获取view在父视图中的索引位置 */
- (NSArray *)getClassIndexStringWithObjectArray:(NSArray *)objectArray {
    NSMutableArray *stringClasses = [NSMutableArray array];
    for (UIView *view in objectArray) {
        if (view.superview) {
            [stringClasses addObject:NSStringFromClass(view.class)];
        } else {
            //  顶层UIWindow对象  特殊处理，后续需要删除
            [stringClasses addObject:@"topWindow"];
        }
    }
    return stringClasses;
}



@end
