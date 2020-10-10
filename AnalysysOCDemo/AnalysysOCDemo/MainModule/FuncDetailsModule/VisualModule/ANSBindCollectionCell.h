//
//  ANSBindCollectionCell.h
//  AnalysysSDKDemo
//
//  Created by xiao xu on 2020/2/11.
//  Copyright © 2020 shaochong du. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ANSBindCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIButton *clickBtn;

@end

NS_ASSUME_NONNULL_END
