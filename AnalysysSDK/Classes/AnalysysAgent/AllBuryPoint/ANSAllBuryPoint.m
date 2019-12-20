//
//  ANSBuryPoint.m
//  AnalysysAgent
//
//  Created by xiao xu on 2019/10/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSAllBuryPoint.h"
#import "ANSSwizzler.h"
#import "ANSProtocolSwizzler.h"
#import "AnalysysAgent.h"
#import "NSThread+ANSHelper.h"
#import <UIKit/UIKit.h>
#import "ANSAllBuryPointModel.h"
#import "UIView+ANSAutoTrack.h"
#import "NSObject+ANSSwizzling.h"
#import "AnalysysSDK.h"
#import "ANSQueue.h"
#import "ANSControllerUtils.h"
@implementation UIGestureRecognizer (ANSAllBuryPointTapGestureRecognizer)
- (void)allBuryPointClick:(UIGestureRecognizer *)gesture {
    
    if([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
        if (gesture.state != UIGestureRecognizerStateEnded) {
            return;
        }
        UIView *view = gesture.view;
        // 暂定只采集 UILabel 和 UIImageView
        BOOL isTrackClass = [view isKindOfClass:UILabel.class] || [view isKindOfClass:UIImageView.class];
        if (!isTrackClass) {
            return;
        }
        UIViewController *vc = [ANSControllerUtils findViewControllerByView:view];
        
        if ([[ANSAllBuryPoint sharedManager] checkIsReport:view withTargat:vc]) {
            [self packageDataWithView:view];
        } else {
            
        }
        
    } else {
        
    }
}

- (instancetype)ans_initWithTarget:(id)target action:(SEL)action {
    [self ans_initWithTarget:target action:action];
    [self removeTarget:target action:action];
    [self addTarget:target action:action];
    return self;
}

- (void)ans_addTarget:(id)target action:(SEL)action {
    [self ans_addTarget:self action:@selector(allBuryPointClick:)];
    [self ans_addTarget:target action:action];
}

- (void)packageDataWithView:(UIView *)view {
    ANSAllBuryPointModel *model = [[ANSAllBuryPointModel alloc] init];
    model.element_id = view.ansViewID;
    model.element_type = view.analysysElementType;
    model.element_path = view.analysysElementPath;
    model.element_content = view.analysysElementContent;
    model.title = view.analysysViewControllerTitle;
    model.url = view.analysysViewControllerName;
    [ANSAllBuryPoint trackAllBuryPoint:[model toDictionary]];
}

@end

@implementation UITableView (ANSAllBuryPointTableView)
- (void)ans_setDelegate:(id <UITableViewDelegate>)delegate {
    [self ans_setDelegate:delegate];
    if (delegate) {
        NSString *hookSelMark = [NSString stringWithFormat:@"%@_tableView:didSelectRowAtIndexPath:",NSStringFromClass([delegate class])];
        [ANSProtocolSwizzler swizzleSelector:@selector(tableView:didSelectRowAtIndexPath:) onClass:[delegate class] withBlock:^(id delegate,SEL command,UITableView *tableView,NSIndexPath *indexPath){
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIViewController *vc = [ANSControllerUtils findViewControllerByView:cell];
            
            if ([[ANSAllBuryPoint sharedManager] checkIsReport:cell withTargat:vc]) {
                [self packageDataWithCell:cell indexPath:indexPath];
            } else {
                
            }
        } named:hookSelMark];
    } else {
        
    }
}

- (void)packageDataWithCell:(id)cell indexPath:(NSIndexPath *)indexPath {
    ANSAllBuryPointModel *model = [[ANSAllBuryPointModel alloc] init];
    model.element_id = ((UITableViewCell *)cell).ansViewID;
    model.element_type = ((UITableViewCell *)cell).analysysElementType;
    model.element_path = ((UITableViewCell *)cell).analysysIndexElementPath;
    model.element_content = ((UITableViewCell *)cell).analysysElementContent;
    model.title = ((UITableViewCell *)cell).analysysViewControllerTitle;
    model.url = ((UITableViewCell *)cell).analysysViewControllerName;
    model.element_position = [((UITableViewCell *)cell) analysysElementPosition:indexPath];
    [ANSAllBuryPoint trackAllBuryPoint:[model toDictionary]];
}
@end

@implementation UICollectionView (ANSAllBuryPointCollectionView)
- (void)ans_setDelegate:(id <UICollectionViewDelegate>)delegate {
    [self ans_setDelegate:delegate];
    if (delegate) {
        NSString *hookSelMark = [NSString stringWithFormat:@"%@_collectionView:didSelectItemAtIndexPath:",NSStringFromClass([delegate class])];
        [ANSProtocolSwizzler swizzleSelector:@selector(collectionView:didSelectItemAtIndexPath:) onClass:[delegate class] withBlock:^(id delegate,SEL command,UICollectionView *collection,NSIndexPath *indexPath){
            UICollectionViewCell *cell = [collection cellForItemAtIndexPath:indexPath];
            UIViewController *vc = [ANSControllerUtils findViewControllerByView:cell];
            
            if ([[ANSAllBuryPoint sharedManager] checkIsReport:cell withTargat:vc]) {
                [self packageDataWithCell:cell indexPath:indexPath];
            } else {
                
            }
        } named:hookSelMark];
    } else {
        
    }
}

- (void)packageDataWithCell:(id)cell indexPath:(NSIndexPath *)indexPath {
    ANSAllBuryPointModel *model = [[ANSAllBuryPointModel alloc] init];
    model.element_id = ((UICollectionViewCell *)cell).ansViewID;
    model.element_type = ((UICollectionViewCell *)cell).analysysElementType;
    model.element_path = ((UICollectionViewCell *)cell).analysysIndexElementPath;
    model.element_content = ((UICollectionViewCell *)cell).analysysElementContent;
    model.title = ((UICollectionViewCell *)cell).analysysViewControllerTitle;
    model.url = ((UICollectionViewCell *)cell).analysysViewControllerName;
    model.element_position = [((UICollectionViewCell *)cell) analysysElementPosition:indexPath];
    [ANSAllBuryPoint trackAllBuryPoint:[model toDictionary]];
}

@end

@interface ANSAllBuryPoint()
@property (nonatomic,strong) NSMutableSet *blackListPages;
@property (nonatomic,strong) NSMutableSet *blackListViewTypes;
@property (nonatomic,strong) NSMutableSet *whiteListPages;
@property (nonatomic,strong) NSMutableSet *whiteListViewTypes;
@end

@implementation ANSAllBuryPoint
+ (instancetype)sharedManager {
    static ANSAllBuryPoint *allBuryPointInstance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        if (!allBuryPointInstance) {
            allBuryPointInstance = [[self alloc] init];
        }
    });
    return allBuryPointInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.blackListPages = [NSMutableSet set];
        self.blackListViewTypes = [NSMutableSet set];
        self.whiteListPages = [NSMutableSet set];
        self.whiteListViewTypes = [NSMutableSet set];
    }
    return self;
}

+ (void)allBuryPointAutoTrack:(BOOL)autoTrack {
    [ANSAllBuryPoint sharedManager].autoTrack = autoTrack;
    
    [UIGestureRecognizer ansExchangeOriginalSel:@selector(addTarget:action:) replacedSel:@selector(ans_addTarget:action:)];
    [UIGestureRecognizer ansExchangeOriginalSel:@selector(initWithTarget:action:) replacedSel:@selector(ans_initWithTarget:action:)];
    [UITableView ansExchangeOriginalSel:@selector(setDelegate:) replacedSel:@selector(ans_setDelegate:)];
    [UICollectionView ansExchangeOriginalSel:@selector(setDelegate:) replacedSel:@selector(ans_setDelegate:)];
    [ANSSwizzler swizzleSelector:@selector(sendAction:to:from:forEvent:) onClass:[UIApplication class] withBlock:^(id view,SEL command,SEL action,id to,id from,UIEvent *event){
        [[self sharedManager] ansSendAction:action to:to from:from forEvent:event];
    } named:@"ANSAllBuryPointSendActionToFromForEvent"];
}

- (BOOL)ansSendAction:(SEL)action to:(nullable id)target from:(nullable id)sender forEvent:(nullable UIEvent *)event {
    if (![sender isKindOfClass:[UIView class]]) {
        return NO;
    }
    // 忽略可视化绑定控件
    NSArray *ignoreActions = @[@"ans_preVerify:forEvent:", @"ans_execute:forEvent:"];
    if ([ignoreActions containsObject:NSStringFromSelector(action)]) {
        return NO;
    }
    if ([self checkIsReport:sender withTargat:target]) {
        [self packageDataWithSender:sender event:event];
        return YES;
    } else {
        return NO;
    }
}

//检查黑白名单，看是否上报
- (BOOL)checkIsReport:(UIView *)view withTargat:(id)target {
    if (self.autoTrack == YES) {
        if (((UIView *)view).autoClickBlackView) {
            return NO;
        } else if ([target isKindOfClass:[UIViewController class]] && ((UIViewController *)target).autoClickBlackPage) {
            return NO;
        } else if ([self.blackListPages containsObject:((UIView *)view).analysysViewControllerName] || [self.blackListViewTypes containsObject:((UIView *)view).analysysElementType]) {
            return NO;
        } else {
            if ((self.whiteListPages.count > 0) || (self.whiteListViewTypes.count > 0)) {
                if ([self.whiteListPages containsObject:((UIView *)view).analysysViewControllerName] ||
                    [self.whiteListViewTypes containsObject:((UIView *)view).analysysElementType]) {
                    return YES;
                } else {
                    return NO;
                }
            } else {
                return YES;
            }
        }
    } else {
        return NO;
    }
}

//View全埋点数据打包上报
- (void)packageDataWithSender:(id)sender event:(UIEvent *)event {
    if ([sender isKindOfClass:[UISwitch class]] ||
        [sender isKindOfClass:[UIStepper class]] ||
        [sender isKindOfClass:[UISegmentedControl class]]) {
        
        ANSAllBuryPointModel *model = [[ANSAllBuryPointModel alloc] init];
        model.element_id = ((UIView *)sender).ansViewID;
        model.element_type = ((UIView *)sender).analysysElementType;
        model.element_path = ((UIView *)sender).analysysElementPath;
        model.element_content = ((UIView *)sender).analysysElementContent;
        model.title = ((UIView *)sender).analysysViewControllerTitle;
        model.url = ((UIView *)sender).analysysViewControllerName;
        [ANSAllBuryPoint trackAllBuryPoint:[model toDictionary]];
        return;
    }
    if (event.type == UIEventTypeTouches) {
        UITouch *touch = [event.allTouches anyObject];
        if (touch.phase == UITouchPhaseEnded && [sender isKindOfClass:[UIView class]]) {
            ANSAllBuryPointModel *model = [[ANSAllBuryPointModel alloc] init];
            model.element_id = ((UIView *)sender).ansViewID;
            model.element_type = ((UIView *)sender).analysysElementType;
            model.element_path = ((UIView *)sender).analysysElementPath;
            model.element_content = ((UIView *)sender).analysysElementContent;
            model.title = ((UIView *)sender).analysysViewControllerTitle;
            model.url = ((UIView *)sender).analysysViewControllerName;
            [ANSAllBuryPoint trackAllBuryPoint:[model toDictionary]];
        }
    }
}

+ (void)trackAllBuryPoint:(NSDictionary *)dictionary {
    [ANSQueue dispatchAsyncLogSerialQueueWithBlock:^{
        [[AnalysysSDK sharedManager] saveUploadInfo:dictionary event:ANSUserClick handler:^{
            
        }];
    }];
}

- (void)setAutoClickBlackListByPages:(NSSet<NSString *> *)controllerNames {
    if (controllerNames.count == 0 || ![controllerNames isKindOfClass:NSSet.class]) {
        return;
    }
    NSSet *sControllers = [controllerNames mutableCopy];
    [self.blackListPages setSet:sControllers];
}

- (void)setAutoClickBlackListByViewTypes:(NSArray<NSString *> *)viewNames {
    if (viewNames.count == 0 || ![viewNames isKindOfClass:NSSet.class]) {
        return;
    }
    NSSet *sViewNames = [viewNames mutableCopy];
    [self.blackListViewTypes setSet:sViewNames];
}

- (void)setAutoClickWhiteListByPages:(NSArray<NSString *> *)controllerNames {
    if (controllerNames.count == 0 || ![controllerNames isKindOfClass:NSSet.class]) {
        return;
    }
    NSSet *sControllers = [controllerNames mutableCopy];
    [self.whiteListPages setSet:sControllers];
}

- (void)setAutoClickWhiteListByViewTypes:(NSArray<NSString *> *)viewNames {
    if (viewNames.count == 0 || ![viewNames isKindOfClass:NSSet.class]) {
        return;
    }
    NSSet *sViewNames = [viewNames mutableCopy];
    [self.whiteListViewTypes setSet:sViewNames];
}

@end
