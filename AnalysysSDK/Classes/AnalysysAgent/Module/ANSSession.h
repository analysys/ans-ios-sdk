//
//  ANSSessionManager.h
//  AnalysysAgent
//
//  Created by SoDo on 2018/12/5.
//  Copyright © 2018 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class
 * ANSSession
 *
 * @abstract
 * session模块
 *
 * @discussion
 * 生成数据中sessionid，跟随上传事件
 * session切换规则，以page展现为判断点（优先级高->低）：
 * 1. App被调起；
 * 2. 两次触发事件跨天；
 * 3. App首次启动；
 * 4. A页面结束时间与B页面开始时间 间隔大于30s
 */


@interface ANSSession : NSObject

+ (instancetype)shareInstance;

/** 当前session */
@property (nonatomic, copy) NSString *sessionId;

/**
 生成session
 */
- (void)generateSessionId;

/**
 session重置
 */
- (void)resetSession;

/// 获取本地session
- (NSString *)localSession;

/**
 * 更新上一页面开始时间
 * 先调用 generateSessionId
 * 1.App启动 2.后台切换至前台 3.页面展现
 */
- (void)updatePageAppearDate;

/**
 * 更新上一页面结束时间
 * 先调用 generateSessionId
 * 1.App启动 2.后台切换至前台 3.前台切换至后台 4.页面消失
 */
- (void)updatePageDisappearDate;



@end


