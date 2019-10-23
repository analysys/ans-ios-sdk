//
//  ANSDefaultStrategy.m
//  AnalysysAgent
//
//  Created by SoDo on 2019/1/17.
//  Copyright © 2019 analysys. All rights reserved.
//

#import "ANSDefaultStrategy.h"
#import "ANSFileManager.h"
#import "ANSStrategyManager.h"


@implementation ANSDefaultStrategy

- (instancetype)init {
    self = [super init];
    if (self) {
        _debugMode = 0;
        _maxAllowFailedCount = 3;
    }
    return self;
}

#pragma mark - ANSStrategyProtocol

- (BOOL)canUploadWithDataCount:(NSInteger)dataCount {
    return YES;
}


@end
