//
//  ANSTableHeaderFooterView.h
//  AnalysysSDKDemo
//
//  Created by SoDo on 2019/11/25.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ANSTableHeaderFooterView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;

@end

NS_ASSUME_NONNULL_END
