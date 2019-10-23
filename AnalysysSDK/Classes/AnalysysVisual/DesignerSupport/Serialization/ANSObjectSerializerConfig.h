//
//  ANSObjectSerializerConfig.h
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

//  ******** 服务器下发的config信息中classes一定要有正确的先后顺序，不然可能导致类的继承关系错误 ********

/**
 * 根据服务器下发classes和enums配置信息生成类描述、枚举描述
 *
 * enums，如：UIControlState、UIControlEvents的枚举值及类型
 * classes，如：UIView、UILabel的属性对应的属性信息及相应父类
 */


#import <Foundation/Foundation.h>

@class ANSEnumDescription;
@class ANSClassDescription;
@class ANSTypeDescription;

@interface ANSObjectSerializerConfig : NSObject

/** 配置信息中类描述 */
@property (nonatomic, readonly) NSArray *classDescriptions;
/** 配置信息中枚举描述 */
@property (nonatomic, readonly) NSArray *enumDescriptions;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (ANSTypeDescription *)typeWithName:(NSString *)name;
- (ANSEnumDescription *)enumWithName:(NSString *)name;
- (ANSClassDescription *)classWithName:(NSString *)name;


@end
