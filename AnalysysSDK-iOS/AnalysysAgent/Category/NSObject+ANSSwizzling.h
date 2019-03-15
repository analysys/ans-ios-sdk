//
//  NSObject+ANSSwizzling.h
//  AnalysysAgent
//
//  Created by analysys on 2017/2/22.
//  Copyright © 2017年 Analysys. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (ANSSwizzling)

+ (void)AnsExchangeOriginalClass:(Class)originalClass
                     originalSel:(SEL)originalSel
                   replacedClass:(Class)replacedClass
                     replacedSel:(SEL)replacedSel;


@end
