//
//  ANSControllerUtils.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/10/16.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSControllerUtils.h"
#import "NSThread+ANSHelper.h"
#import "ANSUtil.h"
#import <UIKit/UIKit.h>

@implementation ANSControllerUtils

+ (NSArray *)systemBuildInClasses {
    static NSArray *systemBlackList ;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        systemBlackList = @[
            @"SFBrowserRemoteViewController",
            @"SFSafariViewController",
            @"UITableViewController",
            @"UIAlertController",
            @"UITabBarController",
            @"UINavigationController",
            @"UIKeyboardCandidateGridCollectionViewController",
            @"UIApplicationRotationFollowingController",
            @"UIApplicationRotationFollowingControllerNoTouches",
            @"AVPlayerViewController",
            @"UIActivityGroupViewController",
            @"UIReferenceLibraryViewController",
            @"UIKeyboardCandidateRowViewController",
            @"UIKeyboardHiddenViewController",
            @"UIImagePickerController",
            @"CAMImagePickerCameraViewController",
            @"CAMViewfinderViewController",
            @"CAMPreviewViewController",
            @"PLPhotoTileViewController",
            @"UIDocumentMenuViewController",
            @"UIActivityViewController",
            @"UIActivityContentViewController",
            @"UISnapshotModalViewController",
            @"WKActionSheet",
            @"DDSafariViewController",
            @"SFAirDropActivityViewController",
            @"_SFAirDropRemoteViewController",
            @"SFAirDropViewController",
            @"CKSMSComposeController",
            @"DDParsecLoadingViewController",
            @"PLUIPrivacyViewController",
            @"PLUICameraViewController",
            @"SLRemoteComposeViewController",
            @"DDParsecNoDataViewController",
            @"DDParsecCollectionViewController",
            @"SLComposeViewController",
            @"DDParsecRemoteCollectionViewController",
            @"AVFullScreenPlaybackControlsViewController",
            @"AVFullScreenViewController",
            @"CKSMSComposeRemoteViewController",
            @"PUPhotoPickerHostViewController",
            @"PUUIAlbumListViewController",
            @"PUUIPhotosAlbumViewController",
            @"PUUIMomentsGridViewController",
            @"PUUIImageViewController",
            @"SFAppAutoFillPasswordViewController",
            @"SFPasswordRemoteViewController",
            @"UIInputWindowController",
            @"UICompatibilityInputViewController",
            @"UISystemInputAssistantViewController",
            @"UIPredictionViewController",
            @"UICandidateViewController",
            @"UIWebRotatingAlertController",
            @"UIEditUserWordController",
            @"UISplitViewController",
            @"UISystemKeyboardDockController",
            @"_UIAlertControllerTextFieldViewController",
            @"_UILongDefinitionViewController",
            @"_UIResilientRemoteViewContainerViewController",
            @"_UIShareExtensionRemoteViewController",
            @"_UIDICActivityViewController",
            @"_UIRemoteDictionaryViewController",
            @"_UINoDefinitionViewController",
            @"_UIActivityGroupListViewController",
            @"_UIRemoteViewController",
            @"_UIFallbackPresentationViewController",
            @"_UIDocumentPickerRemoteViewController",
            @"_UIDocumentActivityViewController",
            @"_UIAlertShimPresentingViewController",
            @"_UIWaitingForRemoteViewContainerViewController",
            @"_UIActivityUserDefaultsViewController",
            @"_UIActivityViewControllerContentController",
            @"_UIRemoteInputViewController",
            @"_UIUserDefaultsActivityNavigationController",
            @"_SFAppPasswordSavingViewController",
            @"_UIActivityNavigationController",
            @"QLPreviewController",
            @"QLPreviewCollection",
            @"QLItemPresenterViewController",
            @"QLErrorItemViewController",
            @"QLPageViewController",
            @"SKRemoteReviewViewController",
            @"SKStoreReviewViewController",
            @"UIEditingOverlayViewController",
            @"MFMessageComposeViewController",
            @"MFMailComposeRemoteViewController",
            @"MFMailComposeViewController",
            @"MFMailComposeInternalViewController"
        ];
    });
    return systemBlackList;
}

+ (UIViewController *)currentViewController {
    __block UIViewController *currentViewController = nil;
    void (^block)(void) = ^{
        UIWindow *window = [ANSUtil currentKeyWindow];
        UIViewController *rootViewController = window.rootViewController;
        NSArray *allProperties = [ANSUtil allPropertiesWithObject:rootViewController.class];
        if ([allProperties containsObject:@"m_tabBarController"]) {
            id object = [rootViewController valueForKey:@"m_tabBarController"];
            if ([object isKindOfClass:NSClassFromString(@"AKTabBarController")]) {
                UIViewController *tabBarController = (UIViewController *)object;
                if ([tabBarController respondsToSelector:NSSelectorFromString(@"selectedViewController")]) {
                    UIViewController *nav = [tabBarController performSelector:NSSelectorFromString(@"selectedViewController") withObject:nil];
                    if ([nav respondsToSelector:NSSelectorFromString(@"topViewController")]) {
                        currentViewController = [nav performSelector:NSSelectorFromString(@"topViewController")];
                    }
                }
            }
        } else {
            currentViewController = [ANSControllerUtils findCurrentVCFromRootVC:rootViewController isRoot:YES];
        }
    };
    [NSThread ansRunOnMainThread:block];

    return currentViewController;
}

+ (UIViewController *)findViewControllerByView:(UIView *)view {
    UIViewController *viewController = [ANSControllerUtils findNextViewControllerByResponder:view];
    if ([viewController isKindOfClass:UINavigationController.class]) {
        viewController = [ANSControllerUtils currentViewController];
    }
    return viewController;
}

+ (NSString *)titleFromViewController:(UIViewController *)viewController {
    __block NSString *title;
    [NSThread ansRunOnMainThread:^{
        title = viewController.navigationItem.title ?: viewController.title;
        if (!title) {
            UIView *titleView = viewController.navigationItem.titleView;
            if (titleView) {
                title = [self contentFromView:titleView];
            }
        }
    }];
    return title;
}

+ (NSString *)contentFromView:(UIView *)view {
    NSMutableString *content = [NSMutableString string];
    NSMutableArray *contentArray = [NSMutableArray array];
    
    [ANSControllerUtils getContentFromView:view contentArray:contentArray];
    
    if (contentArray.count > 0) {
        [content appendString:[contentArray componentsJoinedByString:@"-"]];
    }
    
    return content;
}

+ (UIViewController *)rootViewController {
    UIWindow *window = [ANSUtil currentKeyWindow];
    UIViewController *result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    if ([result isKindOfClass:[UITabBarController class]]) {
        return result;
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)result topViewController];
    }
    return result;
}

+ (NSArray *)allShowViewControllers {
    NSMutableArray *controllers = [NSMutableArray array];
    [self getChildrenVCWithParentVC:[ANSUtil currentKeyWindow].rootViewController allVC:controllers];
    return [controllers copy];
}

#pragma mark - private

//  当前控件及所有子控件
+ (void)getChildrenVCWithParentVC:(UIViewController *)parentVC allVC:(NSMutableArray *)allControllers {
    
    if (parentVC) {
        [allControllers addObject:parentVC];
    }
    
    NSArray *childViewControllers = parentVC.childViewControllers;
    if (parentVC.presentedViewController) {
        childViewControllers = @[parentVC.presentedViewController];
    }
    for (UIViewController *childVC in childViewControllers) {
        //NSLog(@"childVC:%@", childVC);
        [self getChildrenVCWithParentVC:childVC allVC:allControllers];
    }
}

+ (UIViewController *)findCurrentVCFromRootVC:(UIViewController *)viewController isRoot:(BOOL)isRoot {
    UIViewController *currentViewController = nil;
    if (viewController.presentedViewController) {
        viewController = [self findCurrentVCFromRootVC:viewController.presentedViewController isRoot:NO];
    }
    
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        currentViewController = [self findCurrentVCFromRootVC:[(UITabBarController *)viewController selectedViewController] isRoot:NO];
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        // 根视图为UINavigationController
        currentViewController = [self findCurrentVCFromRootVC:[(UINavigationController *)viewController visibleViewController] isRoot:NO];
    } else if ([viewController respondsToSelector:NSSelectorFromString(@"contentViewController")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        UIViewController *tempViewController = [viewController performSelector:NSSelectorFromString(@"contentViewController")];
#pragma clang diagnostic pop
        if (tempViewController) {
            currentViewController = [self findCurrentVCFromRootVC:tempViewController isRoot:NO];
        }
    } else if ([viewController respondsToSelector:NSSelectorFromString(@"selectedViewController")]) {
        //  RDVTabBarController
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        UIViewController *tabNav = [viewController performSelector:NSSelectorFromString(@"selectedViewController")];
#pragma clang diagnostic pop
        if (tabNav) {
            currentViewController = [self findCurrentVCFromRootVC:tabNav isRoot:NO];
        }
    } else if (viewController.childViewControllers.count == 1 && isRoot) {
        currentViewController = [self findCurrentVCFromRootVC:viewController.childViewControllers.firstObject isRoot:NO];
    } else if (viewController.childViewControllers.count > 1) {
        //  MMDrawerController
        BOOL containNavi = NO;
        for (UIViewController *vc in viewController.childViewControllers) {
            if ([vc isKindOfClass:UINavigationController.class]) {
                currentViewController = [self findCurrentVCFromRootVC:vc isRoot:NO];
                containNavi = YES;
                break;
            }
        }
        if (!containNavi) {
            currentViewController = [self findCurrentVCFromRootVC:viewController.childViewControllers.lastObject isRoot:NO];
        }
    } else {
        currentViewController = viewController;
    }
    return currentViewController;
}

+ (UIViewController *)findNextViewControllerByResponder:(UIResponder *)responder {
    UIResponder *next = [responder nextResponder];
    do {
        if ([next isKindOfClass:UIViewController.class]) {
            UIViewController *vc = (UIViewController *)next;
            if ([vc isKindOfClass:UINavigationController.class]) {
                next = [(UINavigationController *)vc topViewController];
                break;
            } else if ([vc isKindOfClass:UITabBarController.class]) {
                next = [(UITabBarController *)vc selectedViewController];
                break;
            }
            UIViewController *parentVC = vc.parentViewController;
            if (parentVC) {
                if ([parentVC isKindOfClass:UINavigationController.class] ||
                    [parentVC isKindOfClass:UITabBarController.class] ||
                    [parentVC isKindOfClass:UIPageViewController.class] ||
                    [parentVC isKindOfClass:UISplitViewController.class]) {
                    break;
                }
            } else {
                break;
            }
        }
    } while ((next = next.nextResponder));
    return [next isKindOfClass:UIViewController.class] ? (UIViewController *)next : nil;
}

/** 递归获取文本内容 */
+ (void)getContentFromView:(UIView *)view contentArray:(NSMutableArray *)contentArray {
    [NSThread ansRunOnMainThread:^{
        for (UIView *subview in view.subviews) {
            if (subview.hidden) {
                continue;
            }
            if ([subview isKindOfClass:UILabel.class]) {
                UILabel *label = (UILabel *)subview;
                NSString *text = label.text;
                if (text.length > 0) {
                    [contentArray addObject:text];
                    continue;
                }
            }
            [ANSControllerUtils getContentFromView:subview contentArray:contentArray];
        }
    }];
}

@end
