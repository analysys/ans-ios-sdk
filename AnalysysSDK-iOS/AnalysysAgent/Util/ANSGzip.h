//
//  ANSGzip.h
//  AnalysysAgent
//
//  Created by analysys on 2018/2/27.
//  Copyright © 2018年 analysys. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class
 * ANSGzip
 *
 * @abstract
 * 数据压缩及解压
 *
 * @discussion
 * Gzip压缩、解压
 */

@interface ANSGzip : NSObject

/** 压缩 */
+ (NSData*)gzipData:(NSData*)pUncompressedData;

/** 解压缩 */
+ (NSData*)ungzipData:(NSData *)compressedData;

@end
