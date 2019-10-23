//
//  NSObject+ANSSwizzling.h
//  AnalysysAgent
//
//  Created by analysys on 2017/2/22.
//  Copyright © 2017年 Analysys. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (ANSSwizzling)

+ (void)AnsExchangeOriginalSel:(SEL)originalSel replacedSel:(SEL)replacedSel;

@end
