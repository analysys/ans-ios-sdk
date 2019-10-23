//
//  ANSHeatMapFunc.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/3/19.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSHeatMapFunc.h"
#import <UIKit/UIKit.h>
#import "ANSHeatMapAutoTrack.h"

@implementation ANSHeatMapFunc

+ (CGFloat)getPageWidth {
    return [[UIScreen mainScreen] bounds].size.width;
}

+ (CGFloat)getPageHeight {
    return [[UIScreen mainScreen] bounds].size.height;
}

+ (CGFloat)getClickX {
    return [ANSHeatMapAutoTrack sharedManager].viewToWindowPoint.x;
}

+ (CGFloat)getClickY {
    return [ANSHeatMapAutoTrack sharedManager].viewToWindowPoint.y;
}

+ (CGFloat)getElementX {
    return [ANSHeatMapAutoTrack sharedManager].viewToParentPoint.x;
}

+ (CGFloat)getElementY {
    return [ANSHeatMapAutoTrack sharedManager].viewToParentPoint.y;
}

+ (NSString *)getElementPath {
    return [ANSHeatMapAutoTrack sharedManager].elementPath;
}

+ (NSString *)getElementID {
    return [ANSHeatMapAutoTrack sharedManager].viewId;
}

+ (NSString *)getElementType {
    return [ANSHeatMapAutoTrack sharedManager].elementType;
}

+ (NSString *)getElementName {
    return [ANSHeatMapAutoTrack sharedManager].viewControllerName;
}

+ (NSString *)getElementContent {
    return [ANSHeatMapAutoTrack sharedManager].elementContent;
}

+ (NSInteger)getElementClickable {
    return [ANSHeatMapAutoTrack sharedManager].elementClickable;
}
@end

