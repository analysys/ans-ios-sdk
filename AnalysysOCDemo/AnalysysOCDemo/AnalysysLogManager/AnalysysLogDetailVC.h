//
//  AnalysysLogDetailVC.h
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/27.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnalysysLogDetailVC : UIViewController
@property (nonatomic,strong) NSMutableDictionary *logDic;
@property (weak, nonatomic) IBOutlet UITextView *logTV;
@end

NS_ASSUME_NONNULL_END
