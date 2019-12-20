//
//  ANSDemoTableViewCell.m
//  AnalysysSDKDemo
//
//  Created by SoDo on 2019/9/20.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSDemoTableViewCell.h"

@implementation ANSDemoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)likeAction:(id)sender {
    NSLog(@"like action");
}
- (IBAction)indexAction:(id)sender {
    NSLog(@"index action");
}

@end
