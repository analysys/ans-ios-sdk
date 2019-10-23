//
//  ANSUITableViewBinding.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSUITableViewBinding.h"

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "ANSSwizzler.h"
#import "ANSConsoleLog.h"

@implementation ANSUITableViewBinding


+ (NSString *)typeName
{
    return @"ui_table_view";
}

+ (ANSEventBinding *)bindingWithJSONObject:(NSDictionary *)object
{
    NSString *path = object[@"path"];
    if (![path isKindOfClass:[NSString class]] || path.length < 1) {
        AnsDebug(@"must supply a view path to bind by");
        return nil;
    }
    
    NSString *eventName = object[@"event_name"];
    if (![eventName isKindOfClass:[NSString class]] || eventName.length < 1 ) {
        AnsDebug(@"binding requires an event name");
        return nil;
    }
    
    Class tableDelegate = NSClassFromString(object[@"table_delegate"]);
    if (!tableDelegate) {
        AnsDebug(@"binding requires a table_delegate class");
        return nil;
    }
    
    return [[ANSUITableViewBinding alloc] initWithEventName:eventName
                                                    onPath:path
                                              withDelegate:tableDelegate
                                               bindingInfo:object];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
+ (ANSEventBinding *)bindngWithJSONObject:(NSDictionary *)object
{
    return [self bindingWithJSONObject:object];
}
#pragma clang diagnostic pop

- (instancetype)initWithEventName:(NSString *)eventName
                           onPath:(NSString *)path
                     withDelegate:(Class)delegateClass
                      bindingInfo:(NSDictionary *)bindingInfo
{
    if (self = [super initWithEventName:eventName onPath:path matchText:@"" bindingInfo:bindingInfo]) {
        [self setSwizzleClass:delegateClass];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"UITableView Event Tracking: '%@' for '%@'", [self eventName], [self path]];
}


#pragma mark -- Executing Actions

- (void)executeVisualEventBinding
{
    if (!self.running && self.swizzleClass != nil) {
        void (^block)(id, SEL, id, id) = ^(id view, SEL command, UITableView *tableView, NSIndexPath *indexPath) {
            NSObject *root = [UIApplication sharedApplication].keyWindow.rootViewController;
            // select targets based off path
            if (tableView && [self.path isLeafSelected:tableView fromRoot:root]) {
//                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//                NSString *label = (cell && cell.textLabel && cell.textLabel.text) ? cell.textLabel.text : @"";
//                NSDictionary *properties = @{
//                                             @"cell_index": [NSString stringWithFormat: @"%ld", (unsigned long)indexPath.row],
//                                             @"cell_section": [NSString stringWithFormat: @"%ld", (unsigned long)indexPath.section],
//                                             @"cell_label": label
//                                             };
//                [[self class] track:self.eventName properties:properties];
                [[self class] trackObject:tableView withEventBinding:self];
            }
        };
        
        [ANSSwizzler swizzleSelector:@selector(tableView:didSelectRowAtIndexPath:)
                            onClass:self.swizzleClass
                          withBlock:block
                              named:self.name];
        self.running = true;
    }
}

- (void)stop
{
    if (self.running && self.swizzleClass != nil) {
        [ANSSwizzler unswizzleSelector:@selector(tableView:didSelectRowAtIndexPath:)
                              onClass:self.swizzleClass
                                named:self.name];
        self.running = false;
    }
}

#pragma mark -- Helper Methods

- (UITableView *)parentTableView:(UIView *)cell {
    // iterate up the view hierarchy to find the table containing this cell/view
    UIView *aView = cell.superview;
    while (aView != nil) {
        if ([aView isKindOfClass:[UITableView class]]) {
            return (UITableView *)aView;
        }
        aView = aView.superview;
    }
    return nil; // this view is not within a tableView
}


@end
