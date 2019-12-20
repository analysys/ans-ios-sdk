//
//  UIView+ANSAllBuryIdentifer.m
//  AnalysysAgent
//
//  Created by xiao xu on 2019/11/6.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "UIView+ANSAllBuryIdentifer.h"
#import <objc/runtime.h>
#pragma mark - UIView
@implementation UIView (ANSAllBuryIdentifer)
- (NSString *)ans_analysysViewIndex {
    NSUInteger viewIndex = 0;
    if (self.superview) {
        viewIndex = [self.superview.subviews indexOfObject:self];
    }
    return [NSString stringWithFormat:@"%lu",(unsigned long)viewIndex];
}

- (NSString *)ans_analysysViewType {
    return NSStringFromClass(self.class);
}

- (NSString *)ans_analysysViewText {
    return nil;
}

- (NSString *)ans_analysysViewControllerName {
    if ([self.nextResponder isKindOfClass:[UIViewController class]]) {
        return NSStringFromClass([self.nextResponder class]);
    } else {
        return nil;
    }
}

- (NSString *)ans_analysysCellReuseIdentifier {
    return nil;
}

- (NSDictionary *)ans_analysysViewIdentifer {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.ans_analysysViewIndex forKey:@"viewIndex"];
    [dic setObject:self.ans_analysysViewType forKey:@"viewType"];
    if (self.ans_analysysViewControllerName) {
        [dic setObject:self.ans_analysysViewControllerName forKey:@"ViewControllerName"];
    }
    return dic;
}

- (NSArray *)ans_analysysViewPath {
    NSMutableArray *array = [NSMutableArray array];
    UIView *currentView = self;
    do {
        [array addObject:currentView.ans_analysysViewIdentifer];
        currentView = currentView.superview;
    } while (currentView);
    
    return [[array reverseObjectEnumerator] allObjects];
}

@end

@implementation UILabel (ANSAllBuryIdentifer)

- (NSString *)ans_analysysViewText {
    return [NSString stringWithFormat:@"%@",self.text?:@""];
}

- (NSDictionary *)ans_analysysViewIdentifer {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.ans_analysysViewIndex forKey:@"viewIndex"];
    [dic setObject:self.ans_analysysViewType forKey:@"viewType"];
    [dic setObject:self.ans_analysysViewText forKey:@"viewText"];
    return dic;
}

@end

#pragma mark - UIControl
@implementation UIButton (ANSAllBuryIdentifer)

- (NSString *)ans_analysysViewText {
    return [NSString stringWithFormat:@"%@",self.titleLabel.text?:@""];
}

- (NSDictionary *)ans_analysysViewIdentifer {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.ans_analysysViewIndex forKey:@"viewIndex"];
    [dic setObject:self.ans_analysysViewType forKey:@"viewType"];
    [dic setObject:self.ans_analysysViewText forKey:@"viewText"];
    return dic;
}

@end

#pragma mark - Cell

@implementation UITableViewCell (ANSAllBuryIdentifer)

static const char * ans_tableviewcell_indexpath = "ans_tableviewcell_indexpath";
- (NSIndexPath *)ans_cellIndexPath {
    return objc_getAssociatedObject(self, ans_tableviewcell_indexpath);
}
- (void)setAns_cellIndexPath:(NSIndexPath *)cellIndexPath {
    objc_setAssociatedObject(self, ans_tableviewcell_indexpath, cellIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)ans_analysysCellReuseIdentifier {
    return self.reuseIdentifier;
}

- (NSDictionary *)ans_analysysViewIdentifer {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.ans_analysysViewType forKey:@"viewType"];
    if (self.ans_analysysCellReuseIdentifier) {
        [dic setObject:self.ans_analysysCellReuseIdentifier forKey:@"viewReuseIdentifier"];
    }
    if (self.ans_cellIndexPath) {
        [dic setObject:@(self.ans_cellIndexPath.section) forKey:@"section"];
        [dic setObject:@(self.ans_cellIndexPath.row) forKey:@"row"];
    }
    return dic;
}

@end

@implementation UICollectionViewCell (ANSAllBuryIdentifer)

static const char * ans_collectionviewcell_indexpath = "ans_collectionviewcell_indexpath";
- (NSIndexPath *)ans_cellIndexPath {
    return objc_getAssociatedObject(self, ans_collectionviewcell_indexpath);
}
- (void)setAns_cellIndexPath:(NSIndexPath *)cellIndexPath {
    objc_setAssociatedObject(self, ans_collectionviewcell_indexpath, cellIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)ans_analysysCellReuseIdentifier {
    return self.reuseIdentifier;
}

- (NSDictionary *)ans_analysysViewIdentifer {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.ans_analysysViewType forKey:@"viewType"];
    if (self.ans_analysysCellReuseIdentifier) {
        [dic setObject:self.ans_analysysCellReuseIdentifier forKey:@"viewReuseIdentifier"];
    }
    if (self.ans_cellIndexPath) {
        [dic setObject:@(self.ans_cellIndexPath.section) forKey:@"section"];
        [dic setObject:@(self.ans_cellIndexPath.item) forKey:@"item"];
    }
    return dic;
}
@end
