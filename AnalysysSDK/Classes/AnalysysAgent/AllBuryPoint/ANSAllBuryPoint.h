//
//  ANSBuryPoint.h
//  AnalysysAgent
//
//  Created by xiao xu on 2019/10/22.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface UIGestureRecognizer (ANSAllBuryPointTapGestureRecognizer)

@end

@interface UITableView (ANSAllBuryPointTableView)

@end

@interface UICollectionView (ANSAllBuryPointCollectionView)

@end

@interface ANSAllBuryPoint : NSObject
@property (nonatomic, assign) BOOL autoTrack;
+ (instancetype)sharedManager;
+ (void)allBuryPointAutoTrack:(BOOL)autoTrack;
+ (void)trackAllBuryPoint:(NSDictionary *)dictionary;

//检查黑白名单，看是否上报
- (BOOL)checkIsReport:(UIView *)view withTargat:(id)target;

/**
  忽略当前集合页面上所有点击事件
 */
- (void)setAutoClickBlackListByPages:(NSSet<NSString *> *)controllerNames;

/**
  忽略当前集合控件点击事件
*/
- (void)setAutoClickBlackListByViewTypes:(NSSet<NSString *> *)viewNames;

/**
  只上报当前集合页面内点击事件
*/
- (void)setAutoClickWhiteListByPages:(NSSet<NSString *> *)controllerNames;

/**
  只上报当前集合控件点击事件
*/
- (void)setAutoClickWhiteListByViewTypes:(NSSet<NSString *> *)viewNames;


@end

NS_ASSUME_NONNULL_END
