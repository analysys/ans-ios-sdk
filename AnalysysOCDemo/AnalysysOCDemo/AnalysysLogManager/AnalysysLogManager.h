//
//  AnalysysLogManager.h
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/27.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnalysysLogManager : NSObject
@property(weak,nonatomic)UIButton *button;
+ (instancetype)sharedSingleton;
- (void)createSuspendButton;
@end

NS_ASSUME_NONNULL_END
