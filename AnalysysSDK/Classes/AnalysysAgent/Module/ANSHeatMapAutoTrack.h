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
@property (atomic, assign) CGPoint viewToWindowPoint;
/** 相对父视图坐标 */
@property (atomic, assign) CGPoint viewToParentPoint;
/** 元素标识 */
@property (atomic, copy) NSString *viewId;
/** 元素所在页面标识 */
@property (atomic, copy) NSString *viewControllerName;
/** 元素类型 如：uibutton、uiswitch等 */
@property (atomic, copy) NSString *elementType;
/** 文本信息 */
@property (atomic, copy) NSString *elementContent;
/** 元素路径 */
@property (atomic, copy) NSString *elementPath;
/** 是否可点击控件 */
@property (atomic, assign) BOOL elementClickable;

+ (instancetype)sharedManager;

/**
 采集热图数据

 @param autoTrack YES/NO
 */
+ (void)heatMapAutoTrack:(BOOL)autoTrack;


@end


