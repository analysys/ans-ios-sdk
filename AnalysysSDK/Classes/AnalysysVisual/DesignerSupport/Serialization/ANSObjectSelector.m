//
//  ANSObjectSelector.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSObjectSelector.h"

#import <UIKit/UIKit.h>
#import "NSThread+AnsHelper.h"
#import "ANSUtil.h"

/**
 * 主要存放解析出的path路径信息
 * 使用 ANSObjectFilter 对象对视图进行过滤判断
 */
@interface ANSObjectFilter : NSObject

@property (nonatomic, strong) NSString *className;// 控件名称
@property (nonatomic, strong) NSPredicate *predicate;// 过滤条件 tag==10 或  文本内容
@property (nonatomic, strong) NSNumber *indexOfSuperView;   // 相对父视图同类 isKindOfClass/isMemberOfClass
@property (nonatomic, assign) BOOL unique;
@property (nonatomic, assign) BOOL nameOnly;

- (NSArray *)apply:(NSArray *)views;
- (NSArray *)applyReverse:(NSArray *)views;
- (BOOL)appliesTo:(NSObject *)view;
- (BOOL)appliesToAny:(NSArray *)views;

@end


@interface ANSObjectSelector () {
    NSCharacterSet *_classAndPropertyChars;
    NSCharacterSet *_separatorChars;
    NSCharacterSet *_predicateStartChar;
    NSCharacterSet *_predicateEndChar;
    NSCharacterSet *_flagStartChar;
    NSCharacterSet *_flagEndChar;
}

@property (nonatomic, strong) NSScanner *scanner;
@property (nonatomic, strong) NSArray *filters;

@end




@implementation ANSObjectSelector

+ (ANSObjectSelector *)objectSelectorWithString:(NSString *)string {
    return [[ANSObjectSelector alloc] initWithPathString:string];
}

- (instancetype)initWithPathString:(NSString *)string {
    if (self = [super init]) {
        _pathString = string;
        _scanner = [NSScanner scannerWithString:_pathString];
        [_scanner setCharactersToBeSkipped:nil];
        _separatorChars = [NSCharacterSet characterSetWithCharactersInString:@"/"];
        _predicateStartChar = [NSCharacterSet characterSetWithCharactersInString:@"["];
        _predicateEndChar = [NSCharacterSet characterSetWithCharactersInString:@"]"];
        _classAndPropertyChars = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.*"];
        _flagStartChar = [NSCharacterSet characterSetWithCharactersInString:@"("];
        _flagEndChar = [NSCharacterSet characterSetWithCharactersInString:@")"];
        
        NSMutableArray *filters = [NSMutableArray array];
        ANSObjectFilter *filter;
        while ((filter = [self nextFilter])) {
            [filters addObject:filter];
        }
        self.filters = [filters copy];
    }
    return self;
}

//  /UITabBarController/ViewController/UIView/UILabel[(eg_fingerprintVersion >= 1 AND eg_varE == \"86b789b444903fb89282c183c9163d8a9d4ad57e\")]
//  将path路径每一部分按照'/'挨个进行处理并封装成EGObjectFilter对象
- (ANSObjectFilter *)nextFilter {
    ANSObjectFilter *filter;
    if ([_scanner scanCharactersFromSet:_separatorChars intoString:nil]) {
        NSString *name;
        filter = [[ANSObjectFilter alloc] init];
        if ([_scanner scanCharactersFromSet:_classAndPropertyChars intoString:&name]) {
            filter.className = name;
        } else {
            filter.className = @"*";
        }
        if ([_scanner scanCharactersFromSet:_flagStartChar intoString:nil]) {
            NSString *flags;
            [_scanner scanUpToCharactersFromSet:_flagEndChar intoString:&flags];
            for (NSString *flag in[flags componentsSeparatedByString:@"|"]) {
                if ([flag isEqualToString:@"unique"]) {
                    filter.unique = YES;
                }
            }
        }
        if ([_scanner scanCharactersFromSet:_predicateStartChar intoString:nil]) {
            NSString *predicateFormat;
            NSInteger index = 0;
            if ([_scanner scanInteger:&index] && [_scanner scanCharactersFromSet:_predicateEndChar intoString:nil]) {
                filter.indexOfSuperView = @((NSUInteger)index);
            } else {
                [_scanner scanUpToCharactersFromSet:_predicateEndChar intoString:&predicateFormat];
                @try {
                    NSPredicate *parsedPredicate = [NSPredicate predicateWithFormat:predicateFormat];
                    filter.predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                        //  对已过滤出的视图进行 predicate 条件过滤，如：tag==100等
                        @try {
                            return [parsedPredicate evaluateWithObject:evaluatedObject substitutionVariables:bindings];
                        } @catch (NSException *exception) {
                            return false;
                        }
                    }];
                } @catch (NSException *exception) {
                    filter.predicate = [NSPredicate predicateWithValue:NO];
                }
                
                [_scanner scanCharactersFromSet:_predicateEndChar intoString:nil];
            }
        }
    }
    return filter;
}

//  根据path从根视图查找所有能够匹配路径的子视图对象集合（父视图->子视图）
- (NSArray *)selectFromRoot:(id)root {
    return [self selectFromRoot:root evaluatingFinalPredicate:YES];
}

- (NSArray *)fuzzySelectFromRoot:(id)root {
    return [self selectFromRoot:root evaluatingFinalPredicate:NO];
}

/** 根据传入对象自 父->子 向下遍历，返回所有满足条件的控件 */
- (NSArray *)selectFromRoot:(id)root evaluatingFinalPredicate:(BOOL)finalPredicate {
    if (!root) return nil;
    
    NSArray *views = @[root];
    //  通过filter对象个数决定遍历对象深度，并使用每层filter进行过滤
    NSUInteger i = 0, n = _filters.count;
    for (ANSObjectFilter *filter in _filters) {
        //  末节节点是否只使用名称匹配
        filter.nameOnly = (i == n-1 && !finalPredicate);
        views = [filter apply:views];
        if (views.count == 0) {
            //  如果当前视图个数为0则直接返回
            break;
        }
        i++;
    }
    return views;
}

/** 从下而上（子视图->父视图） 查找当前控件是否与路径匹配 */
- (BOOL)isLeafSelected:(id)leaf fromRoot:(id)root {
    return [self isLeafSelected:leaf fromRoot:root evaluatingFinalPredicate:YES];
}

- (BOOL)fuzzyIsLeafSelected:(id)leaf fromRoot:(id)root {
    return [self isLeafSelected:leaf fromRoot:root evaluatingFinalPredicate:NO];
}

/**
 自 点击控件开始 向上查找是否当前所有父节点都满足path相同层级的filter条件

 @param leaf 当前控件
 @param root 根视图
 @param finalPredicate 是否使用predicate过滤
 @return 路径是否匹配
 */
- (BOOL)isLeafSelected:(id)leaf fromRoot:(id)root evaluatingFinalPredicate:(BOOL)finalPredicate {
    BOOL isNodeMatch = YES;
    NSArray *views = @[leaf];
    NSUInteger n = _filters.count, i = n;
    while (i--) {
        ANSObjectFilter *filter = _filters[i];
        filter.nameOnly = (i == n-1 && !finalPredicate);
        if (![filter appliesToAny:views]) {
            isNodeMatch = NO;
            break;
        }
        
        views = [filter applyReverse:views];
        if (views.count == 0) {
            break;
        }
    }
    return isNodeMatch && [views indexOfObject:root] != NSNotFound;
}

/** 取 _filters 末尾节点作为当前视图 */
- (Class)selectedClass {
    ANSObjectFilter *filter = _filters.lastObject;
    if (filter) {
        return NSClassFromString(filter.className);
    }
    return nil;
}

/** path路径中节点是否为klass的子类 */
- (BOOL)pathContainsObjectOfClass:(Class)klass {
    for (ANSObjectFilter *filter in _filters) {
        if ([NSClassFromString(filter.className) isSubclassOfClass:klass]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)description {
    return self.pathString;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (![other isKindOfClass:[ANSObjectSelector class]]) {
        return NO;
    } else {
        return [self.pathString isEqual:((ANSObjectSelector *)other).pathString];
    }
}

- (NSUInteger)hash {
    return [self.pathString hash];
}


@end



@implementation ANSObjectFilter

- (instancetype)init {
    if ((self = [super init])) {
        self.unique = NO;
        self.nameOnly = NO;
    }
    return self;
}

/** 使用filter，匹配当前视图的所有子视图 */
- (NSArray *)apply:(NSArray *)views {
    NSMutableArray *result = [NSMutableArray array];
    
    Class class = NSClassFromString(_className);
    if (class || [_className isEqualToString:@"*"]) {
        for (NSObject *view in views) {
            NSArray *children = [self getChildrenOfObject:view ofType:class];
            if (_indexOfSuperView && _indexOfSuperView.unsignedIntegerValue < children.count) {
                //  当前视图必须为UIView子类
//                if ([view isKindOfClass:[UIView class]]) {
                    children = @[children[_indexOfSuperView.unsignedIntegerValue]];
//                } else {
//                    children = @[];
//                }
            }
            [result addObjectsFromArray:children];
        }
    }
    
    if (!self.nameOnly) {
        // If unique is set and there are more than one, return nothing
        if (self.unique && result.count != 1) {
            return @[];
        }
        //  根据predicate进行视图过滤 如:tag==100
        if (self.predicate) {
            return [result filteredArrayUsingPredicate:self.predicate];
        }
    }
    return [result copy];
}

/** 匹配当前兄弟节点所有视图是否满足filter，若满足则返回该视图的上层节点 */
- (NSArray *)applyReverse:(NSArray *)views {
    NSMutableArray *result = [NSMutableArray array];
    for (NSObject *view in views) {
        if ([self appliesTo:view]) {
            [result addObjectsFromArray:[self getParentsOfObject:view]];
        }
    }
    return [result copy];
}

/** 当前视图是否满足filter过滤条件 */
- (BOOL)appliesTo:(NSObject *)view {
    return (([self.className isEqualToString:@"*"] || [view isKindOfClass:NSClassFromString(self.className)])
            && (self.nameOnly || (
                                  (!self.predicate || [_predicate evaluateWithObject:view]) && (!self.indexOfSuperView || [self isView:view siblingNumber:_indexOfSuperView.integerValue]) &&
                                  (!(self.unique) || [self isView:view oneOfNSiblings:1])))
            );
}

/** 判断当前视图是否满足filter过滤条件 */
- (BOOL)appliesToAny:(NSArray *)views {
    for (NSObject *view in views) {
        if ([self appliesTo:view]) {
            return YES;
        }
    }
    return NO;
}

/*
 Returns true if the given view is at the index given by number in
 its parent's subviews. The view's parent must be of type UIView
 */
/** view 视图在兄弟节点索引 number 是否正确 */
- (BOOL)isView:(NSObject *)view siblingNumber:(NSInteger)number {
    return [self isView:view siblingNumber:number of:-1];
}

- (BOOL)isView:(NSObject *)view oneOfNSiblings:(NSInteger)number {
    return [self isView:view siblingNumber:-1 of:number];
}

/** 根据path中index判断当前视图在兄弟节点的位置是否正确 */
- (BOOL)isView:(NSObject *)view siblingNumber:(NSInteger)index of:(NSInteger)numSiblings {
    NSArray *parents = [self getParentsOfObject:view];
    for (NSObject *parent in parents) {
        if ([parent isKindOfClass:[UIView class]]) {
            NSArray *siblings = [self getChildrenOfObject:parent ofType:NSClassFromString(_className)];
            if ((index < 0 || ((NSUInteger)index < siblings.count && siblings[(NSUInteger)index] == view))
                && (numSiblings < 0 || siblings.count == (NSUInteger)numSiblings)) {
                return YES;
            }
        }
    }
    return NO;
}

/** 获取对象的父对象 */
- (NSArray *)getParentsOfObject:(NSObject *)obj {
    NSMutableArray *result = [NSMutableArray array];
    if ([obj isKindOfClass:[UIView class]]) {
        UIView *v = (UIView *)obj;
        UIView *superview = [v superview];
        if (superview) {
            [result addObject:superview];
        }
        UIResponder *nextResponder = [v nextResponder];
        // For UIView, nextResponder should be its controller or its superview.
        if (nextResponder && nextResponder != superview) {
            [result addObject:nextResponder];
        }
    } else if ([obj isKindOfClass:[UIViewController class]]) {
        UIViewController *parentViewController = [(UIViewController *)obj parentViewController];
        if (parentViewController) {
            [result addObject:parentViewController];
        }
        UIViewController *presentingViewController = [(UIViewController *)obj presentingViewController];
        if (presentingViewController) {
            [result addObject:presentingViewController];
        }
        UIWindow *keyWindow = [ANSUtil currentKeyWindow];
        if (keyWindow.rootViewController == obj) {
            //TODO is there a better way to get the actual window that has this VC
            [result addObject:keyWindow];
        }
    }
    return [result copy];
}

/** 获取某个对象所有子视图和堆栈中与class相同的对象 */
- (NSArray *)getChildrenOfObject:(NSObject *)obj ofType:(Class)class {
    NSMutableArray *children = [NSMutableArray array];
    // A UIWindow is also a UIView, so we could in theory follow the subviews chain from UIWindow, but
    // for now we only follow rootViewController from UIView.
    if ([obj isKindOfClass:[UIWindow class]]) {
        NSArray *subviews = [ANSUtil currentKeyWindow].subviews;
        if (subviews.count > 1) {
            //  弹窗直接添加至UIWindow类型的视图
            for (NSObject *child in subviews) {
                if ([child isMemberOfClass:class]) {
                    [children addObject:child];
                }
            }
        } else {
            UIViewController *rootViewController = ((UIWindow *)obj).rootViewController;
            if ([rootViewController isKindOfClass:class]) {
                [children addObject:rootViewController];
            }
        }
    } else if ([obj isKindOfClass:[UIView class]]) {
        // NB. For UIViews, only add subviews, nothing else.
        // The ordering of this result is critical to being able to
        // apply the index filter.
        
        __block NSArray *subviews;
        [NSThread ansRunOnMainThread:^{
            subviews = [[(UIView *)obj subviews] copy];
        }];
        for (NSObject *child in subviews) {
            if (!class || [child isKindOfClass:class]) {
                [children addObject:child];
            }
        }
    } else if ([obj isKindOfClass:[UIViewController class]]) {
        UIViewController *viewController = (UIViewController *)obj;
        for (NSObject *child in [viewController childViewControllers]) {
            if (!class || [child isKindOfClass:class]) {
                [children addObject:child];
            }
        }
        UIViewController *presentedViewController = viewController.presentedViewController;
        if (presentedViewController && (!class || [presentedViewController isKindOfClass:class])) {
            [children addObject:presentedViewController];
        }
        if (!class || (viewController.isViewLoaded && [viewController.view isKindOfClass:class])) {
            [children addObject:viewController.view];
        }
    }
    NSArray *result;
    // Reorder the cells in a table view so that they are arranged by y position
    if ([class isSubclassOfClass:[UITableViewCell class]]) {
        result = [children sortedArrayUsingComparator:^NSComparisonResult(UIView *obj1, UIView *obj2) {
            if (obj2.frame.origin.y > obj1.frame.origin.y) {
                return NSOrderedAscending;
            } else if (obj2.frame.origin.y < obj1.frame.origin.y) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
    } else {
        result = [children copy];
    }
    return result;
}

- (NSString *)description;{
    return [NSString stringWithFormat:@"%@[%@]", self.className, self.indexOfSuperView ?: self.predicate];
}

@end


