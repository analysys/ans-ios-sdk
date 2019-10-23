//
//  UnitTestCase.m
//  AnalysysSDK-iOS
//
//  Created by SoDo on 2019/8/6.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "UnitTestCase.h"
#import <AnalysysSDK/AnalysysAgent.h>

@implementation UnitTestCase


#pragma mark - Track

+ (void)track_0 {
    [AnalysysAgent track:@"payAction"];
}

+ (void)track_1 {
    [AnalysysAgent track:@"" properties:@""];
}

+ (void)track_2 {
    NSObject *obj = [NSObject new];
    [AnalysysAgent track:@"action" properties:@{
                                                @"objectArrayValue": @[@"text", obj, [NSDate date]],
                                                @"%YUT&^G": @"特殊字符key",
                                                @"nilArray": @[],
                                                @"normalKey": @"normalValue",
                                                @"sapceValue": @"    ",
                                                @"nilStringValue":@"",
                                                @"nilStringArrayValue": @[@""],
                                                @"arrayValue": @[@"aa", @"bb", @"", @"  "],
                                                @"": @"key为空",
                                                @"objectValue": obj,
                                                @"nullValue": [NSNull null],
                                                @"$lib":@"iOS"
                                                }];
    
    //    [AnalysysAgent track:@"testA" properties:@{@"keyA": @[[NSNull null], @"aaa"]}];
    //    NSString *keyStr = [self getStringWithLength:100];
    //    [AnalysysAgent track:@"testD" properties:@{keyStr: @"dddd"}];
}

+ (void)track_3 {
    [AnalysysAgent track:@".1^~" properties:@""];
}

+ (void)track_4 {
    [AnalysysAgent track:nil properties:@""];
}

+ (void)track_5 {
    [AnalysysAgent track:@"testEvent" properties:@[]];
}

+ (void)track_6 {
    NSString *mutString = [self getStringWithLength:9999];
    [AnalysysAgent track:@"testEvent" properties:@{@"keyddd":mutString.copy}];
}

+ (void)track_7 {
    NSString *mutString = [self getStringWithLength:100];
    [AnalysysAgent track:mutString.copy properties:@{@"keyddd":@"value"}];
}

+ (void)track_8 {
    [AnalysysAgent track:@"map" properties:@{@"key": @{@"aaaa": @"aaaa"},
                                             @"$lib":@"iOS",
                                             @"ttttt": @""}];
}

#pragma mark - PageView

+ (void)pageView_0 {
    [AnalysysAgent pageView:@"SinglePageView"];
    
    NSMutableString *str = [NSMutableString string];
    for (int i = 0; i < 256; i++) {
        [str appendFormat:@"a"];
    }
    [AnalysysAgent pageView:nil properties:@{@"kkkk": str, @"array": @[str]}];
}

+ (void)pageView_1 {
    [AnalysysAgent pageView:@"" properties:@""];
}

+ (void)pageView_2 {
    NSObject *obj = [NSObject new];
    [AnalysysAgent pageView:nil properties:@{
                                             @"objectArrayValue": @[@"text", obj, [NSDate date]],
                                             @"%YUT&^G": @"特殊字符key",
                                             @"nilArray": @[],
                                             @"normalKey": @"normalValue",
                                             @"sapceValue": @"    ",
                                             @"nilStringValue":@"",
                                             @"nilStringArrayValue": @[@""],
                                             @"arrayValue": @[@"aa", @"bb", @"", @"  "],
                                             @"": @"key为空",
                                             @"objectValue": obj,
                                             @"nullValue": [NSNull null],
                                             @"$lib":@"iOS"
                                             }];

}

+ (void)pageView_3 {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 101; i++) {
        [array addObject:[NSString stringWithFormat:@"%d", i]];
    }
    NSDictionary *dic = @{@"key": array};
    [AnalysysAgent pageView:@"ViewName" properties:dic];
}

+ (void)pageView_4 {
    [AnalysysAgent pageView:NSObject.new properties:nil];
}

+ (void)pageView_5 {
    [AnalysysAgent pageView:@"Home" properties:@[@1, @2]];
}

+ (void)pageView_6 {
    [AnalysysAgent pageView:@".1^~" properties:nil];
}

+ (void)pageView_7 {
    NSString *mutString = [self getStringWithLength:9999];
    [AnalysysAgent pageView:mutString.copy properties:nil];
}

#pragma mark - super property

+ (void)superProperty_0 {
    
    [AnalysysAgent registerSuperProperties:@"非法数据"];
    
    NSString *string = [self getStringWithLength:8193];
    [AnalysysAgent registerSuperProperties:@{@"VIPLevel":@"Silver",
                                             @"Hobby":@[@"Singing",@"Reading",string]
                                             }];
}

+ (void)superProperty_1 {
    NSString *kkk = [NSString stringWithFormat:@"key_%d", arc4random()%10];
    [AnalysysAgent registerSuperProperty:kkk value:@"isfhljhkhui"];
}

+ (void)superProperty_2 {
    NSDictionary *SProperties = [AnalysysAgent getSuperProperties];
}

+ (void)superProperty_3 {
    [AnalysysAgent unRegisterSuperProperty:@"key_0"];
    
    [AnalysysAgent unRegisterSuperProperty:@""];
}

+ (void)superProperty_3:(NSString *)key {
    [AnalysysAgent unRegisterSuperProperty:key];
}

+ (void)superProperty_4 {
    id properties = [AnalysysAgent getSuperProperty:@"key_1"];
}

+ (void)superProperty_4:(NSString *)key {
    id properties = [AnalysysAgent getSuperProperty:key];
}

+ (void)superProperty_5 {
    [AnalysysAgent clearSuperProperties];
}

#pragma mark - alias

+ (void)alias_0 {
    [AnalysysAgent alias:@"zhangsan" originalId:@""];
}

+ (void)alias_1 {
    NSString *originalId = [self getStringWithLength:256];
    [AnalysysAgent alias:@"zhangsan" originalId:originalId];
}

+ (void)alias_2 {
    int aliasRandom = arc4random() % 10;
    NSString *aliasId = [NSString stringWithFormat:@"analysys_%d", aliasRandom];
    NSString *originalId = [NSString stringWithFormat:@"origin_%d", aliasRandom];
    if (aliasRandom == 5) {
        originalId = nil;
    }
    
    [AnalysysAgent alias:aliasId originalId:originalId];
}

+ (void)alias_3 {
    [AnalysysAgent identify:[NSString stringWithFormat:@"identity_id %d", arc4random()%10]];
}

+ (void)alias_4 {
    [AnalysysAgent identify:@""];
    
    [AnalysysAgent identify:[self getStringWithLength:256]];
}

#pragma mark - profileset

+ (void)profileSet_0 {
    [AnalysysAgent profileSet:nil];
}

+ (void)profileSet_1 {
    [AnalysysAgent profileSet:@{}];
}

+ (void)profileSet_2 {
    [AnalysysAgent profileSet:@""];
}

+ (void)profileSet_3 {
    NSObject *obj = [NSObject new];
    [AnalysysAgent profileSet:@{
                                @"objectArrayValue": @[@"text", obj, [NSDate date]],
                                @"%YUT&^G": @"特殊字符key",
                                @"nilArray": @[],
                                @"Hobby": @"paly football",
                                @"sapceValue": @"    ",
                                @"nilStringValue":@"",
                                @"nilStringArrayValue": @[@""],
                                @"arrayValue": @[@"aa", @"bb", @"", @"  "],
                                @"": @"key为空",
                                @"objectValue": obj,
                                @"nullValue": [NSNull null],
                                @"$lib":@"iOS"
                                }];
}

+ (void)profileSet_4 {
    [AnalysysAgent profileSet:@{@"dff":@[@1,@56]}];
}

+ (void)profileSet_5 {
//    [AnalysysAgent profileSet:[NSObject new]];
    [AnalysysAgent profileSet:[NSArray new]];
}

+ (void)profileSet_6 {
    [AnalysysAgent profileSet:@"lisi"];
}

#pragma mark - profile set once

+ (void)profileSetOnce_0 {
    [AnalysysAgent profileSetOnce:nil];
}

+ (void)profileSetOnce_1 {
    [AnalysysAgent profileSetOnce:@{}];
}

+ (void)profileSetOnce_2 {
    [AnalysysAgent profileSetOnce:@""];
}

+ (void)profileSetOnce_3 {
    NSObject *obj = [NSObject new];
    [AnalysysAgent profileSetOnce:@{
                                    @"objectArrayValue": @[@"text", obj, [NSDate date]],
                                    @"%YUT&^G": @"特殊字符key",
                                    @"nilArray": @[],
                                    @"normalKey": @"normalValue",
                                    @"sapceValue": @"    ",
                                    @"nilStringValue":@"",
                                    @"nilStringArrayValue": @[@""],
                                    @"arrayValue": @[@"aa", @"bb", @"", @"  "],
                                    @"": @"key为空",
                                    @"objectValue": obj,
                                    @"nullValue": [NSNull null],
                                    @"$lib":@"iOS"
                                    }];
}

+ (void)profileSetOnce_4 {
    [AnalysysAgent profileSetOnce:@{@"dff":@[@1,@56]}];
}

+ (void)profileSetOnce_5 {
    [AnalysysAgent profileSetOnce:[NSArray new]];
}

+ (void)profileSetOnce_6 {
    [AnalysysAgent profileSetOnce:@"string"];
}

#pragma mark - ProfileIncrement

+ (void)profileIncrement_0 {
    [AnalysysAgent profileIncrement:nil];
}

+ (void)profileIncrement_1 {
    [AnalysysAgent profileIncrement:@{}];
}

+ (void)profileIncrement_2 {
    [AnalysysAgent profileIncrement:@""];
}

+ (void)profileIncrement_3 {
    NSObject *obj = [NSObject new];
    [AnalysysAgent profileIncrement:@{
                                      @"objectArrayValue": @[@"text", obj, [NSDate date]],
                                      @"%YUT&^G": @"特殊字符key",
                                      @"nilArray": @[],
                                      @"normalKey": @"normalValue",
                                      @"sapceValue": @"    ",
                                      @"nilStringValue":@"",
                                      @"nilStringArrayValue": @[@""],
                                      @"arrayValue": @[@"aa", @"bb", @"", @"  "],
                                      @"": @"key为空",
                                      @"objectValue": obj,
                                      @"nullValue": [NSNull null],
                                      @"$lib":@"iOS",
                                      @"testKey":@(100)
                                      }];
}

+ (void)profileIncrement_4{
    [AnalysysAgent profileIncrement:@{@"dff":@[@1,@56]}];
}

+ (void)profileIncrement_5{
    [AnalysysAgent profileIncrement:[NSArray new]];
}

+ (void)profileIncrement_6 {
    [AnalysysAgent profileIncrement:@"string"];
}

#pragma mark - ProfileAppend

+ (void)profileAppend_0 {
    [AnalysysAgent profileAppend:nil];
}

+ (void)profileAppend_1 {
    [AnalysysAgent profileAppend:@{}];
}

+ (void)profileAppend_2 {
    [AnalysysAgent profileAppend:@""];
}

+ (void)profileAppend_3 {
    NSObject *obj = [NSObject new];
    [AnalysysAgent profileAppend:@{
                                   @"objectArrayValue": @[@"text", obj, [NSDate date]],
                                   @"%YUT&^G": @"特殊字符key",
                                   @"nilArray": @[],
                                   @"normalKey": @"normalValue",
                                   @"sapceValue": @"    ",
                                   @"nilStringValue":@"",
                                   @"nilStringArrayValue": @[@""],
                                   @"arrayValue": @[@"aa", @"bb", @"", @"  "],
                                   @"": @"key为空",
                                   @"objectValue": obj,
                                   @"nullValue": [NSNull null],
                                   @"$lib":@"iOS",
                                   @"testKey":@(100)
                                   }];
}

+ (void)profileAppend_4 {
    [AnalysysAgent profileAppend:@"aaa" value:@"sdfsdf"];
}

+ (void)profileAppend_5 {
    NSObject *obj = [NSObject new];
    [AnalysysAgent profileAppend:@"apend" propertyValue:[NSSet setWithObjects:@"obj1",@"obj2", nil]];
}

+ (void)profileAppend_6 {
    [AnalysysAgent profileAppend:@{@"testKey":@[@"",@"fdfdfd"],@"keyfff":@"ddd"}];
}

#pragma mark - other

+ (NSString *)getStringWithLength:(int)length {
    NSMutableString *mutString = [[NSMutableString alloc] initWithString:@""];
    int i = length;
    while (i >0) {
        [mutString appendFormat:@"a"];
        i--;
    }
    return mutString.copy;
}

@end
