//
//  ANSBindTableViewCell.h
//  AnalysysSDKDemo
//
//  Created by xiao xu on 2020/2/5.
//  Copyright © 2020 shaochong du. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ANSBindTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *ans_titleLab;
@property (weak, nonatomic) IBOutlet UIButton *ans_clickBtn;

@end

NS_ASSUME_NONNULL_END
