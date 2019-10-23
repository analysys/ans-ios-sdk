//
//  ANSDemoTableViewCell.h
//  AnalysysSDKDemo
//
//  Created by SoDo on 2019/9/20.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ANSDemoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailBtn;

@end

NS_ASSUME_NONNULL_END
