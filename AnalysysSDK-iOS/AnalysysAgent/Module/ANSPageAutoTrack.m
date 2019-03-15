//
//  ANSPageAutoTrack.m
//  AnalysysAgent
//
//  Created by SoDo on 2018/12/10.
//  Copyright © 2018 analysys. All rights reserved.
//

#import "ANSPageAutoTrack.h"

#import <UIKit/UIKit.h>
#import "ANSSwizzler.h"
#import "ANSSession.h"
#import "AnalysysSDK.h"

@interface ANSPageAutoTrack ()

@property (nonatomic, strong) NSArray *systemBuildInClasses;
@property (nonatomic, strong) NSMutableDictionary *lastVisitPageInfo; // 最后访问的页面信息

@end

@implementation ANSPageAutoTrack

+ (instancetype)shareInstance {
    static id singleInstance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        singleInstance = [[self alloc] init] ;
    });
    return singleInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lastVisitPageInfo = [NSMutableDictionary dictionary];
        _systemBuildInClasses = @[
                                  @"SFBrowserRemoteViewController",
                                  @"SFSafariViewController",
                                  @"UIAlertController",
                                  @"UIInputWindowController",
                                  @"UITabBarController",
                                  @"UINavigationController",
                                  @"UIKeyboardCandidateGridCollectionViewController",
                                  @"UICompatibilityInputViewController",
                                  @"UIApplicationRotationFollowingController",
                                  @"UIApplicationRotationFollowingControllerNoTouches",
                                  @"AVPlayerViewController",
                                  @"UIActivityGroupViewController",
                                  @"UIReferenceLibraryViewController",
                                  @"UIKeyboardCandidateRowViewController",
                                  @"UIKeyboardHiddenViewController",
                                  @"_UIAlertControllerTextFieldViewController",
                                  @"_UILongDefinitionViewController",
                                  @"_UIResilientRemoteViewContainerViewController",
                                  @"_UIShareExtensionRemoteViewController",
                                  @"_UIDICActivityViewController",
                                  @"_UIRemoteDictionaryViewController",
                                  @"UISystemKeyboardDockController",
                                  @"_UINoDefinitionViewController",
                                  @"UIImagePickerController",
                                  @"_UIActivityGroupListViewController",
                                  @"_UIRemoteViewController",
                                  @"_UIFallbackPresentationViewController",
                                  @"_UIDocumentPickerRemoteViewController",
                                  @"_UIAlertShimPresentingViewController",
                                  @"_UIWaitingForRemoteViewContainerViewController",
                                  @"UIDocumentMenuViewController",
                                  @"UIActivityViewController",
                                  @"_UIActivityUserDefaultsViewController",
                                  @"_UIActivityViewControllerContentController",
                                  @"_UIRemoteInputViewController",
                                  @"UIViewController",
                                  @"UITableViewController",
                                  @"_UIUserDefaultsActivityNavigationController",
                                  @"UISnapshotModalViewController",
                                  @"WKActionSheet",
                                  @"DDSafariViewController",
                                  @"SFAirDropActivityViewController",
                                  @"CKSMSComposeController",
                                  @"DDParsecLoadingViewController",
                                  @"PLUIPrivacyViewController",
                                  @"PLUICameraViewController",
                                  @"SLRemoteComposeViewController",
                                  @"CAMViewfinderViewController",
                                  @"DDParsecNoDataViewController",
                                  @"CAMPreviewViewController",
                                  @"DDParsecCollectionViewController",
                                  @"SLComposeViewController",
                                  @"DDParsecRemoteCollectionViewController",
                                  @"AVFullScreenPlaybackControlsViewController",
                                  @"PLPhotoTileViewController",
                                  @"AVFullScreenViewController",
                                  @"CAMImagePickerCameraViewController",
                                  @"CKSMSComposeRemoteViewController",
                                  @"PUPhotoPickerHostViewController",
                                  @"PUUIAlbumListViewController",
                                  @"PUUIPhotosAlbumViewController",
                                  @"SFAppAutoFillPasswordViewController",
                                  @"PUUIMomentsGridViewController",
                                  @"SFPasswordRemoteViewController"
                                  ];
    }
    return self;
}

+ (void)autoTrack {
    if ([NSThread isMainThread]) {
        void (^viewDidAppearBlock)(id, SEL, id) = ^(id obj, SEL sel, NSNumber *num) {
            UIViewController *controller = (UIViewController *)obj;
            if ([self isBuildInViewController:controller]) {
                return;
            }
            //  先生成session 后记录时间
            [[ANSSession shareInstance] generateSessionId];
            [[ANSSession shareInstance] updatePageAppearDate];
            
            [[ANSPageAutoTrack shareInstance] trackPageDidAppear:controller];
        };
        void (^viewDidDisappearBlock)(id, SEL, id) = ^(id obj, SEL sel, NSNumber *num) {
            UIViewController *controller = (UIViewController *)obj;
            if ([self isBuildInViewController:controller]) {
                return;
            }
            //  更新页面结束时间
            [[ANSSession shareInstance] updatePageDisappearDate];
        };
        [ANSSwizzler swizzleBoolSelector:@selector(viewDidAppear:) onClass:[UIViewController class] withBlock:viewDidAppearBlock named:@"AnsViewDidAppear"];
        [ANSSwizzler swizzleBoolSelector:@selector(viewDidDisappear:) onClass:[UIViewController class] withBlock:viewDidDisappearBlock named:@"AnsViewDidDisappear"];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self autoTrack];
        });
    }
}

+ (void)autoTrackLastVisitPage {
    NSDictionary *pageInfo = [ANSPageAutoTrack shareInstance].lastVisitPageInfo;
    if (pageInfo.allKeys.count) {
        [[AnalysysSDK sharedManager] pageView:nil properties:pageInfo];
    }
}

#pragma mark *** private method ***

/** 页面自动采集 */
- (void)trackPageDidAppear:(UIViewController *)controller {
    [self.lastVisitPageInfo removeAllObjects];
    NSString *className = NSStringFromClass([controller class]);
    if ([[AnalysysSDK sharedManager] isViewAutoTrack] &&
        ![_systemBuildInClasses containsObject:className] &&
        ![[AnalysysSDK sharedManager] isIgnoreTrackWithClassName:className]) {
        //  允许自动采集且未忽略页面
        NSString *controllerTitle = controller.navigationItem.title;
        if (controllerTitle.length) {
            self.lastVisitPageInfo[@"$title"] = controllerTitle;
        }
        self.lastVisitPageInfo[@"$url"] = className;
        [[AnalysysSDK sharedManager] pageView:nil properties:self.lastVisitPageInfo];
    }
}

/** 是否系统内置controller */
+ (BOOL)isBuildInViewController:(UIViewController *)controller {
    if ([controller childViewControllers].count > 0) {
        return YES;
    }
    Class cClass = [controller class];
    if (!cClass) {
        return YES;
    }
    if ([[ANSPageAutoTrack shareInstance].systemBuildInClasses containsObject:NSStringFromClass(cClass)]) {
        return YES;
    }
    if ([controller isKindOfClass:[UINavigationController class]] ||
        [controller isKindOfClass:[UITabBarController class]]) {
        return YES;
    }
    return NO;
}

@end
