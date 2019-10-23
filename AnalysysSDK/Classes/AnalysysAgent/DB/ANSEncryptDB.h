//
//  ANSEncryptDB.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/5/28.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ANSEncryptDB : NSObject

+ (NSString *)base64EncodeWithString:(NSString *)str;

+ (NSString *)base64DecodeWithString:(NSString *)base64Str;

@end


