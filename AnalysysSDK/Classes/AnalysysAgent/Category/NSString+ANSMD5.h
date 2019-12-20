//
//  NSString+ANSMD5.h
//  AnalysysAgent
//
//  Created by SoDo on 2018/11/29.
//  Copyright © 2018 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (ANSMD5)

/// MD5 32位字符串
- (NSString *)ansMD532Bit;

/// MD5 16位字符串
- (NSString *)ansMD516Bit;

@end

NS_ASSUME_NONNULL_END
