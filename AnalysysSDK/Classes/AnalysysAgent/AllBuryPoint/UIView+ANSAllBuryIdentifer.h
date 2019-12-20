//
//  UIView+ANSAllBuryIdentifer.h
//  AnalysysAgent
//
//  Created by xiao xu on 2019/11/6.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ANSAllBuryIdentiferProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface UIView (ANSAllBuryIdentifer) <ANSAllBuryIdentiferProtocol>

@end

@interface UILabel (ANSAllBuryIdentifer) <ANSAllBuryIdentiferProtocol>

@end

@interface UITextView (ANSAllBuryIdentifer)<ANSAllBuryIdentiferProtocol>

@end

@interface UIProgressView (ANSAllBuryIdentifer)<ANSAllBuryIdentiferProtocol>

@end

@interface UIImageView (ANSAllBuryIdentifer)<ANSAllBuryIdentiferProtocol>

@end

@interface UITabBar (ANSAllBuryIdentifer)<ANSAllBuryIdentiferProtocol>

@end

@interface UINavigationBar (ANSAllBuryIdentifer)<ANSAllBuryIdentiferProtocol>

@end

@interface UISearchBar (ANSAllBuryIdentifer)<ANSAllBuryIdentiferProtocol>

@end



#pragma mark - UIControl

@interface UIControl (ANSAllBuryIdentifer)<ANSAllBuryIdentiferProtocol>

@end

@interface UIButton (ANSAllBuryIdentifer)<ANSAllBuryIdentiferProtocol>

@end

@interface UIDatePicker (ANSAllBuryIdentifer)<ANSAllBuryIdentiferProtocol>

@end

@interface UIPageControl (ANSAllBuryIdentifer)<ANSAllBuryIdentiferProtocol>

@end

@interface UISegmentedControl (ANSAllBuryIdentifer)<ANSAllBuryIdentiferProtocol>

@end

@interface UITextField (ANSAllBuryIdentifer)<ANSAllBuryIdentiferProtocol>

@end

@interface UISlider (ANSAllBuryIdentifer)<ANSAllBuryIdentiferProtocol>

@end

@interface UISwitch (ANSAllBuryIdentifer)<ANSAllBuryIdentiferProtocol>

@end

@interface UIStepper (ANSAllBuryIdentifer)<ANSAllBuryIdentiferProtocol>

@end

#pragma mark - Cell

@interface UITableViewCell (ANSAllBuryIdentifer) <ANSAllBuryIdentiferProtocol>
@property (nonatomic, strong) NSIndexPath *ans_cellIndexPath;
@end

@interface UICollectionViewCell (ANSAllBuryIdentifer) <ANSAllBuryIdentiferProtocol>
@property (nonatomic, strong) NSIndexPath *ans_cellIndexPath;
@end

NS_ASSUME_NONNULL_END
