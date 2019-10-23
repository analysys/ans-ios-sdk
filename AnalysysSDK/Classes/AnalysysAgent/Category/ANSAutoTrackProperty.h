//
//  ANSAutoTrackProperty.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/9/27.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class
 * ANSAutoTrackProperty
 *
 * @abstract
 * 控件自动采集时，需获取的属性信息
 *
 * @discussion
 * 自动采集控件需遵循该协议
 */
@protocol ANSAutoTrackProperty <NSObject>

/** 元素标识 */
@property (nonatomic, copy, readonly) NSString *analysysViewId;
/** 元素所在页面标识 */
@property (nonatomic, copy, readonly) NSString *analysysViewControllerName;
/** 元素类型 如：uibutton、uiswitch等 */
@property (nonatomic, copy, readonly) NSString *analysysElementType;
/** 文本信息 */
@property (nonatomic, copy, readonly) NSString *analysysElementContent;
/** 元素路径 */
@property (nonatomic, copy, readonly) NSString *analysysElementPath;
/** 是否可点击控件 */
@property (nonatomic, assign, readonly) BOOL analysysElementClickable;

@end


