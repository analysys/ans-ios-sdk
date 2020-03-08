//
//  ANSListTableViewController.h
//  AnalysysSDKDemo
//
//  Created by SoDo on 2020/1/6.
//  Copyright © 2020 shaochong du. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CallBack)(NSArray*, NSIndexPath *);

@interface ANSListTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *listArray;

@property (nonatomic, copy) CallBack block;

@end

NS_ASSUME_NONNULL_END
