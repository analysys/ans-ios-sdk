//
//  ANSDataCheckLog.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/5/7.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
日志结果

 - AnalysysResultDefault: 默认状态
 - AnalysysResultSetFailed: 设置失败
 - AnalysysResultNotNil: 不能 为空
 - AnalysysResultReservedKey: 保留字段
 - AnalysysResultOutOfString: 字符串超长
 - AnalysysResultIllegalOfString: 字符串不符合规则
 - AnalysysResultTypeError: 类型错误
 - AnalysysResultPropertyValueFixed: 属性被修改，字符串超长被截取,数组中的空字符串移除,集合元素个数超出限制被截取
 - AnalysysResultSuccess:
 - AnalysysResultSetSuccess: 设置成功
*/
typedef NS_ENUM(NSInteger, AnalysysResultType) {
    AnalysysResultDefault = 0,
    AnalysysResultSetFailed,
    AnalysysResultNotNil,
    AnalysysResultReservedKey,
    AnalysysResultOutOfString,
    AnalysysResultIllegalOfString,
    AnalysysResultTypeError,
    AnalysysResultPropertyValueFixed,

    AnalysysResultSuccess ,
    AnalysysResultSetSuccess,
};

/**
 * @class
 * 日志输出
 *
 * @abstract
 * 主要适用于日志校验时 log 输出
 *
 * @discussion
 * 根据不同接口校验结果进行日志输出
 */
@interface ANSDataCheckLog : NSObject

/** 日志类型 */
@property (nonatomic, assign) AnalysysResultType resultType;
/** 关键信息 */
@property (nonatomic, copy) NSString *keyWords;
/** 未修改值 原值 */
@property (nonatomic, strong) id value;
/** 日志备注 */
@property (nonatomic, copy) NSString *remarks;
/** 修改后值信息 */
@property (nonatomic, strong) id valueFixed;

/**
 日志信息

 @return 日志
 */
- (NSString *)messageDisplay;

@end


