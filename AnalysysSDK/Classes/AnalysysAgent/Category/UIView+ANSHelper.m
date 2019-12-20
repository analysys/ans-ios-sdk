//
//  UIView+ANSHelper.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "UIView+ANSHelper.h"

#import <objc/runtime.h>
#import "ANSControllerUtils.h"

// NB If you add any more fingerprint methods, increment this.
#define ANS_FINGERPRINT_VERSION 1

@implementation UIView (ANSHelper)

- (NSString *)encryptString:(id)input {
    if ([input isKindOfClass:[NSString class]]) {
        NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
        NSData *base64Data = [data base64EncodedDataWithOptions:0];
        return [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSArray *)targetActions {
    NSMutableArray *targetActions = [NSMutableArray array];
    if ([self isKindOfClass:[UIControl class]]) {
        for (id target in [(UIControl *)(self) allTargets]) {
            UIControlEvents allEvents = UIControlEventAllTouchEvents | UIControlEventAllEditingEvents;
            for (NSUInteger e = 0; (allEvents >> e) > 0; e++) {
                UIControlEvents event = allEvents & (0x01 << e);
                if (event) {
                    NSArray *actions = [(UIControl *)(self) actionsForTarget:target forControlEvent:event];
                    NSArray *ignoreActions = @[@"ans_preVerify:forEvent:", @"ans_execute:forEvent:"];
                    for (NSString *action in actions) {
                        if ([ignoreActions indexOfObject:action] == NSNotFound)
                        {
                            [targetActions addObject:[NSString stringWithFormat:@"%lu/%@", (unsigned long)event, action]];
                        }
                    }
                }
            }
        }
    }
    return [targetActions copy];
}

- (NSString *)controllerVariable {
    NSString *result = nil;
    if ([self isKindOfClass:[UIControl class]]) {
        UIResponder *responder = [self nextResponder];
        while (responder && ![responder isKindOfClass:[UIViewController class]]) {
            responder = [responder nextResponder];
        }
        if (responder) {
            uint count;
            Ivar *ivars = class_copyIvarList([responder class], &count);
            for (uint i = 0; i < count; i++) {
                Ivar ivar = ivars[i];
                if (ivar_getTypeEncoding(ivar)[0] == '@' && object_getIvar(responder, ivar) == self) {
                    result = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
                    break;
                }
            }
            free(ivars);
        }
    }
    if (result) {
        return result;
    }
    return nil;
}

/*
 Creates a short string which is a fingerprint of a UIButton's image property.
 It does this by downsampling the image to 8x8 and then downsampling the resulting
 32bit pixel data to 8 bit. This should allow us to select images that are identical or
 almost identical in appearance without having to compare the whole image.
 
 Returns a base64 encoded string representing an 8x8 bitmap of 8 bit rgba data
 (2 bits per component).
 */
- (NSString *)imageFingerprint {
    NSString *result = nil;
    UIImage *originalImage = nil;
    if ([self isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)self;
        originalImage = [btn imageForState:btn.state];
    } else if ([NSStringFromClass([self.superview class]) isEqual:@"UITabBarButton"] && [self respondsToSelector:@selector(image)]) {
        originalImage = (UIImage *)[self performSelector:@selector(image)];
    } else if ([self isKindOfClass:UIImageView.class]) {
        UIImageView *imageView = (UIImageView *)self;
        originalImage = imageView.image;
    }
    
    if (originalImage) {
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        uint32_t data32[64];
        uint8_t data4[32];
        CGContextRef context = CGBitmapContextCreate(data32, 8, 8, 8, 8*4, space, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little);
        CGContextSetAllowsAntialiasing(context, NO);
        CGContextClearRect(context, CGRectMake(0, 0, 8, 8));
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        CGContextDrawImage(context, CGRectMake(0,0,8,8), [originalImage CGImage]);
        CGColorSpaceRelease(space);
        CGContextRelease(context);
        for (int i = 0; i < 32; i++) {
            int j = 2*i;
            int k = 2*i + 1;
            data4[i] = (((data32[j] & 0x80000000) >> 24) | ((data32[j] & 0x800000) >> 17) | ((data32[j] & 0x8000) >> 10) | ((data32[j] & 0x80) >> 3) |
                        ((data32[k] & 0x80000000) >> 28) | ((data32[k] & 0x800000) >> 21) | ((data32[k] & 0x8000) >> 14) | ((data32[k] & 0x80) >> 7));
        }
        result = [[NSData dataWithBytes:data4 length:32] base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
    }
    return result;
}

-(void)setAnsViewId:(NSString *)ansViewId {
    objc_setAssociatedObject(self, @selector(ansViewId), [ansViewId copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString *)ansViewId {
    return objc_getAssociatedObject(self, @selector(ansViewId));
}

- (UIImage *)ansSnapshotImage {
    UIImage *image = nil;
    CGSize size = self.layer.bounds.size;
    UIGraphicsBeginImageContext(size);
    @try {
        [self drawViewHierarchyInRect:CGRectMake(0.0f, 0.0f, size.width, size.height) afterScreenUpdates:YES];
        image = UIGraphicsGetImageFromCurrentImageContext();
    } @catch (NSException *exception) {
        NSLog(@"exception getting snapshot image %@ for view %@", exception, self);
    }
    UIGraphicsEndImageContext();
    
    return image;
}

- (NSString *)ansElementText {
    NSString *text = nil;
    SEL titleSelector = @selector(title);
    if ([self isKindOfClass:[UILabel class]]) {
        text = ((UILabel *)self).text;
    } else if ([self isKindOfClass:[UIButton class]]) {
        text = [((UIButton *)self) titleForState:UIControlStateNormal];
    } else if ([self respondsToSelector:titleSelector]) {
        IMP titleImp = [self methodForSelector:titleSelector];
        void *(*func)(id, SEL) = (void *(*)(id, SEL))titleImp;
        id title = (__bridge id)func(self, titleSelector);
        if ([title isKindOfClass:[NSString class]]) {
            text = title;
        }
    } else if ([self isKindOfClass:[NSClassFromString(@"_UIButtonBarButton") class]] ||
                [self isKindOfClass:[NSClassFromString(@"UITabBarButton") class]]) {
        //   该判断热图 获取热图信息需一致(analysysElementContent)
        text = [ANSControllerUtils contentFromView:self];
    }
    return text;
}

#pragma mark - Aliases for compatibility
//  自定义属性，匹配服务器下发属性
//  **** 切勿随意修改 ****
- (int)eg_fingerprintVersion {
    return ANS_FINGERPRINT_VERSION;
}

- (NSString *)eg_varA {
    return [self encryptString:[self ansViewId]];
}

- (NSString *)eg_varB {
    return [self encryptString:[self controllerVariable]];
}

- (NSString *)eg_varC {
    return [self encryptString:[self imageFingerprint]];
}

- (NSArray *)eg_varSetD {
    NSArray *targetActions = [self targetActions];
    NSMutableArray *encryptedActions = [NSMutableArray array];
    for (id targetAction in targetActions) {
        [encryptedActions addObject:[self encryptString:targetAction]];
    }
    return encryptedActions;
}

- (NSString *)eg_varE {
    NSString *varE = [self encryptString:[self ansElementText]];
    return varE;
}

@end
