//
//  ANSABTestDesignerSnapshotResponseMessage.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSABTestDesignerSnapshotResponseMessage.h"

#import <CommonCrypto/CommonDigest.h>
#import "ANSControllerUtils.h"

@implementation ANSABTestDesignerSnapshotResponseMessage


+ (instancetype)message {
    return [(ANSABTestDesignerSnapshotResponseMessage *)[self alloc] initWithType:@"snapshot_response"];
}


/**
 处理截图，生成image_hash  并保存本地

 @param screenshot 当前截图
 */
- (void)setScreenshot:(UIImage *)screenshot {
    id payloadObject = nil;
    id imageHash = nil;
    if (screenshot) {
        NSData *jpegSnapshotImageData = UIImageJPEGRepresentation(screenshot, 0.5);
        if (jpegSnapshotImageData) {
            payloadObject = [jpegSnapshotImageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            imageHash = [self getImageHash:jpegSnapshotImageData];
        }
    }

    _imageHash = imageHash;
    [self setPayloadObject:(payloadObject ?: [NSNull null]) forKey:@"screenshot"];
    [self setPayloadObject:(imageHash ?: [NSNull null]) forKey:@"image_hash"];
}

- (void)addExtroResponseInfo {
    //  与热图模块页面标识同步
    NSString *className = NSStringFromClass([ANSControllerUtils currentViewController].class);
    [self setPayloadObject:(className ?: [NSNull null]) forKey:@"viewController"];
}

- (UIImage *)screenshot {
    NSString *base64Image = [self payloadObjectForKey:@"screenshot"];
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64Image
                                                            options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return imageData ? [UIImage imageWithData:imageData] : nil;
}

/** 保存图层信息 */
- (void)setSerializedObjects:(NSDictionary *)serializedObjects {
    [self setPayloadObject:serializedObjects forKey:@"serialized_objects"];
}

- (NSDictionary *)serializedObjects {
    return [self payloadObjectForKey:@"serialized_objects"];
}

/** image_hash 算法 */
- (NSString *)getImageHash:(NSData *)imageData {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(imageData.bytes, (uint)imageData.length, result);
    NSString *imageHash = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]];
    return imageHash;
}





@end
