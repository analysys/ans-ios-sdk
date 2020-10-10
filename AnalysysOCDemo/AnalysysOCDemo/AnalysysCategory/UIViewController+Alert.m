//
//  UIViewController+Alert.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/17.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "UIViewController+Alert.h"

@implementation UIViewController (Alert)
- (void)showTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* actionDefault = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"确定");
    }];
    
    [alert addAction:actionDefault];
    
    [self presentViewController:alert animated:YES completion:nil];
}
@end
