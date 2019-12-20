//
//  UIView+ANSPathUtils.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/11/19.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ANSPathUtils)


/// 获取视图索引路径，包含末尾tail节点路径计算规则
/// 如：/ANSNavigationViewController/NextViewController/UIView/UITabBar/UITabBarButton[(eg_fingerprintVersion >= 1 AND eg_varE == \"TW9yZQ==\")]
- (NSString *)getElementPath;

/// 获取视图索引路径，不含末尾tail节点路径计算规则
- (NSString *)getIndexElementPath;

@end


