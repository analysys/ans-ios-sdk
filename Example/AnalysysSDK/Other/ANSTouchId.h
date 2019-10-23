//
//  ANSTouchId.h
//  AnalysysSDK-iOS
//
//  Created by SoDo on 2019/6/12.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <LocalAuthentication/LocalAuthentication.h>

/**
 *  TouchID 状态
 */
typedef NS_ENUM(NSUInteger, LzwTouchIDState){
    
    /**
     *  当前设备不支持TouchID
     */
    LzwTouchIDStateNotSupport = 0,
    /**
     *  TouchID 验证成功
     */
    LzwTouchIDStateSuccess = 1,
    
    /**
     *  TouchID 验证失败
     */
    LzwTouchIDStateFail = 2,
    /**
     *  TouchID 被用户手动取消
     */
    LzwTouchIDStateUserCancel = 3,
    /**
     *  用户不使用TouchID,选择手动输入密码
     */
    LzwTouchIDStateInputPassword = 4,
    /**
     *  TouchID 被系统取消 (如遇到来电,锁屏,按了Home键等)
     */
    LzwTouchIDStateSystemCancel = 5,
    /**
     *  TouchID 无法启动,因为用户没有设置密码
     */
    LzwTouchIDStatePasswordNotSet = 6,
    /**
     *  TouchID 无法启动,因为用户没有设置TouchID
     */
    LzwTouchIDStateTouchIDNotSet = 7,
    /**
     *  TouchID 无效
     */
    LzwTouchIDStateTouchIDNotAvailable = 8,
    /**
     *  TouchID 被锁定(连续多次验证TouchID失败,系统需要用户手动输入密码)
     */
    LzwTouchIDStateTouchIDLockout = 9,
    /**
     *  当前软件被挂起并取消了授权 (如App进入了后台等)
     */
    LzwTouchIDStateAppCancel = 10,
    /**
     *  当前软件被挂起并取消了授权 (LAContext对象无效)
     */
    LzwTouchIDStateInvalidContext = 11,
    /**
     *  系统版本不支持TouchID (必须高于iOS 8.0才能使用)
     */
    LzwTouchIDStateVersionNotSupport = 12
};

typedef NS_ENUM(NSUInteger, TDFaceIDState){
    
    LzwFaceIDStateSuccess = 0,
    
    LzwFaceIDStateFail= 1
};

NS_ASSUME_NONNULL_BEGIN

@interface ANSTouchId : LAContext

typedef void (^StateBlock)(LzwTouchIDState state,NSError *error);

typedef void (^faceIDStateBlock)(TDFaceIDState state,NSError *error);


/**
 启动TouchID进行验证
 
 @param desc Touch显示的描述
 @param block 回调状态的block
 */

-(void)lzw_showTouchIDWithDescribe:(NSString *)desc BlockState:(StateBlock)block;

+ (ANSTouchId *)sharedInstance;


/**
 启动FaceID
 
 @param desc FaceID显示的描述
 @param block 验证状态
 */
- (void)lzw_showFaceIDWithDescribe:(NSString *)desc BlockState:(faceIDStateBlock)block;


@end

NS_ASSUME_NONNULL_END
