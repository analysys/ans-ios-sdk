//
//  ANSHeatMapAutoTrack.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/3/19.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

/**
 * @class
 * ANSHeatMapAutoTrack
 *
 * @abstract
 * 热点图采集
 *
 * @discussion
 * 根据用户配置采集用户点击坐标信息
 */

@interface ANSHeatMapAutoTrack : NSObject

/** 相对window坐标 */
@property (nonatomic, assign) CGPoint viewToWindowPoint;
/** 相对父视图坐标 */
@property (nonatomic, assign) CGPoint viewToParentPoint;
/** 元素标识 */
@property (nonatomic, copy) NSString *viewId;
/** 元素所在页面标识 */
@property (nonatomic, copy) NSString *viewControllerName;
/** 元素类型 如：uibutton、uiswitch等 */
@property (nonatomic, copy) NSString *elementType;
/** 文本信息 */
@property (nonatomic, copy) NSString *elementContent;
/** 元素路径 */
@property (nonatomic, copy) NSString *elementPath;
/** 是否可点击控件 */
@property (nonatomic, assign) BOOL elementClickable;
/** 忽略部分页面上所有的点击事件*/
@property (nonatomic, strong) NSMutableSet *ignoreAutoClickPage;
/** 只上报部分页面内点击事件*/
@property (nonatomic, strong) NSMutableSet *autoClickPage;

+ (instancetype)sharedManager;

/**
 采集热图数据

 @param autoTrack YES/NO
 */
+ (void)heatMapAutoTrack:(BOOL)autoTrack;


@end


