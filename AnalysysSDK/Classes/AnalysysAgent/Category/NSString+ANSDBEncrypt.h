//
//  NSString+ANSDBEncrypt.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/10/24.
//  Copyright © 2019 shaochong du. All rights reserved.
//


#import <Foundation/Foundation.h>



@interface NSString (ANSDBEncrypt)

/// 数据加密
- (NSString *)ansBase64Encode;

/// 数据解密
- (NSString *)ansBase64Decode;

@end


