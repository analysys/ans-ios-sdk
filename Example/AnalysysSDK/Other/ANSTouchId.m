//
//  ANSTouchId.m
//  AnalysysSDK-iOS
//
//  Created by SoDo on 2019/6/12.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import "ANSTouchId.h"

@implementation ANSTouchId

+ (instancetype)sharedInstance {
    static ANSTouchId *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ANSTouchId alloc] init];
    });
    return instance;
}

-(void)lzw_showTouchIDWithDescribe:(NSString *)desc BlockState:(StateBlock)block{
    
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"系统版本不支持TouchID (必须高于iOS 8.0才能使用)");
            block(LzwTouchIDStateVersionNotSupport,nil);
        });
        
        return;
    }
    
    LAContext *context = [[LAContext alloc]init];
    
    context.localizedFallbackTitle = desc;
    NSError *error = nil;
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:desc == nil ? @"通过Home键验证已有指纹":desc reply:^(BOOL success, NSError * _Nullable error) {
            
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"TouchID 验证成功");
                    block(LzwTouchIDStateSuccess,error);
                });
            }else if(error){
                
                switch (error.code) {
                    case LAErrorAuthenticationFailed:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"TouchID 验证失败");
                            block(LzwTouchIDStateFail,error);
                        });
                        break;
                    }
                    case LAErrorUserCancel:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"TouchID 被用户手动取消");
                            block(LzwTouchIDStateUserCancel,error);
                        });
                    }
                        break;
                    case LAErrorUserFallback:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"用户不使用TouchID,选择手动输入密码");
                            block(LzwTouchIDStateInputPassword,error);
                        });
                    }
                        break;
                    case LAErrorSystemCancel:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"TouchID 被系统取消 (如遇到来电,锁屏,按了Home键等)");
                            block(LzwTouchIDStateSystemCancel,error);
                        });
                    }
                        break;
                    case LAErrorPasscodeNotSet:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"TouchID 无法启动,因为用户没有设置密码");
                            block(LzwTouchIDStatePasswordNotSet,error);
                        });
                    }
                        break;
                    case LAErrorTouchIDNotEnrolled:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"TouchID 无法启动,因为用户没有设置TouchID");
                            block(LzwTouchIDStateTouchIDNotSet,error);
                        });
                    }
                        break;
                    case LAErrorTouchIDNotAvailable:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"TouchID 无效");
                            block(LzwTouchIDStateTouchIDNotAvailable,error);
                        });
                    }
                        break;
                    case LAErrorTouchIDLockout:{
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"TouchID 无效");
                            block(LzwTouchIDStateTouchIDLockout,error);
                        });
                        
                    }
                        break;
                    case LAErrorAppCancel:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"当前软件被挂起并取消了授权 (如App进入了后台等)");
                            block(LzwTouchIDStateAppCancel,error);
                        });
                    }
                        break;
                    case LAErrorInvalidContext:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"当前软件被挂起并取消了授权 (LAContext对象无效)");
                            block(LzwTouchIDStateInvalidContext,error);
                        });
                    }
                        break;
                    default:
                        break;
                }
            }
        }];
        
    }else{
        
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"用来验证指纹!" reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(LzwTouchIDStateSuccess,error);
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(LzwTouchIDStateFail,error);
                });
                
            }
        }];
        
    }
    
}

-(void)lzw_showFaceIDWithDescribe:(NSString *)desc BlockState:(faceIDStateBlock)block
{
    NSError *error;
    
    LAContext *context = [[LAContext alloc]init];
    
    BOOL canAuthentication = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error];
    if (canAuthentication) {
        
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:desc reply:^(BOOL success, NSError * _Nullable error) {
            //注意iOS 11.3之后需要配置Info.plist权限才可以通过Face ID验证哦!不然只能输密码啦...
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(LzwFaceIDStateSuccess,error);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"当前软件被挂起并取消了授权 (如App进入了后台等)");
                    block(LzwFaceIDStateFail,error);
                });
                
            }
        }];
    }
}

@end
