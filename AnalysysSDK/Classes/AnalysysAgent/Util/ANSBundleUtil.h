//
//  ANSBundleUtil.h
//  AnalysysAgent
//
//  Created by SoDo on 2019/3/7.
//  Copyright © 2019 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ANSBundleUtil : NSObject

/**
 获取资源json数据
 
 @param fileName 文件名称
 @param type 文件类型
 @return 文件数据
 */
+ (id)loadConfigsWithFileName:(NSString *)fileName fileType:(NSString *)type;

@end


