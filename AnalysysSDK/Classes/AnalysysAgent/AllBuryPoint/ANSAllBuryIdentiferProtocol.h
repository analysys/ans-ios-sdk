//
//  ANSAllBuryIdentiferProtocol.h
//  AnalysysAgent
//
//  Created by xiao xu on 2019/11/6.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@protocol ANSAllBuryIdentiferProtocol <NSObject>

/** 控件相对于父控件index */
@property (nonatomic, copy, readonly) NSString *ans_analysysViewIndex;

/** 控件类型 如：uibutton、uiswitch等 */
@property (nonatomic, copy, readonly) NSString *ans_analysysViewType;

/** 控件上的文本 如：uibutton-title、uilabel-text等 */
@property (nonatomic, copy, readonly) NSString *ans_analysysViewText;

/** 控件所属控制器名称 如：UIViewController等 */
@property (nonatomic, copy, readonly) NSString *ans_analysysViewControllerName;

/** cell - reuseIdentifier */
@property (nonatomic, copy, readonly) NSString *ans_analysysCellReuseIdentifier;

/** 控件标识*/
@property (nonatomic, copy, readonly) NSDictionary *ans_analysysViewIdentifer;

/** 控件路径*/
@property (nonatomic, copy, readonly) NSArray *ans_analysysViewPath;

@end

NS_ASSUME_NONNULL_END
