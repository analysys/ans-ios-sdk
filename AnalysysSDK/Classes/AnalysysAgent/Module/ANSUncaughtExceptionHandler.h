//
//  ANSUncaughtExceptionHandler.h
//  bengkui
//
//  Created by xiao xu on 2019/10/17.
//  Copyright © 2019 rainbird. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ANSUncaughtExceptionHandler : NSObject

void ANSHandleException(NSException *exception);
void ANSSignalHandler(int signal, struct __siginfo *info, void *contex);


void ANSInstallUncaughtExceptionHandler(void);
+ (void)reportException:(NSException *)exception;
@end

NS_ASSUME_NONNULL_END
