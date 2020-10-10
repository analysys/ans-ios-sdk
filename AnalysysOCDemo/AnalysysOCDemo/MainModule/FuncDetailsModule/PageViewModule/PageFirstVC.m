//
//  PageFirstVC.m
//  AnalysysOCDemo
//
//  Created by xiao xu on 2020/7/20.
//  Copyright © 2020 xiao xu. All rights reserved.
//

#import "PageFirstVC.h"
#import "PageSecondVC.h"
@interface PageFirstVC () <ANSAutoPageTracker>
- (IBAction)to_page_first:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *page_property_tv;

@end

@implementation PageFirstVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSStringFromClass([self class]);
    
    self.page_property_tv.text = [NSString stringWithFormat:@"registerPageProperties = %@",[self registerPageProperties]];
}

- (NSDictionary *)registerPageProperties {
    return @{@"custom_page_name": @"first_page"};
}

- (IBAction)to_page_first:(id)sender {
    PageSecondVC *pageSecondVC = [[PageSecondVC alloc] init];
    [self.navigationController pushViewController:pageSecondVC animated:YES];
}
@end
