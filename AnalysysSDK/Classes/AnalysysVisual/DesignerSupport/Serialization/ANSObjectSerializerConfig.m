//
//  ANSObjectSerializerConfig.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSObjectSerializerConfig.h"

#import "ANSClassDescription.h"
#import "ANSEnumDescription.h"
#import "ANSTypeDescription.h"

@implementation ANSObjectSerializerConfig {
    NSDictionary *_classes;
    NSDictionary *_enums;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        NSMutableDictionary *classDescriptions = [NSMutableDictionary dictionary];
        for (NSDictionary *d in dictionary[@"classes"]) {
            NSString *superclassName = d[@"superclass"];
            ANSClassDescription *superclassDescription = superclassName ? classDescriptions[superclassName] : nil;
            ANSClassDescription *classDescription = [[ANSClassDescription alloc] initWithSuperclassDescription:superclassDescription dictionary:d];
            
            classDescriptions[classDescription.name] = classDescription;
        }
        
        NSMutableDictionary *enumDescriptions = [NSMutableDictionary dictionary];
        for (NSDictionary *d in dictionary[@"enums"]) {
            ANSEnumDescription *enumDescription = [[ANSEnumDescription alloc] initWithDictionary:d];
            enumDescriptions[enumDescription.name] = enumDescription;
        }
        
        _classes = [classDescriptions copy];
        _enums = [enumDescriptions copy];
    }
    
    return self;
}

- (NSArray *)classDescriptions {
    return _classes.allValues;
}

- (ANSEnumDescription *)enumWithName:(NSString *)name {
    return _enums[name];
}

- (ANSClassDescription *)classWithName:(NSString *)name {
    return _classes[name];
}

- (ANSTypeDescription *)typeWithName:(NSString *)name {
    ANSEnumDescription *enumDescription = [self enumWithName:name];
    if (enumDescription) {
        return enumDescription;
    }
    
    ANSClassDescription *classDescription = [self classWithName:name];
    if (classDescription) {
        return classDescription;
    }
    
    return nil;
}

@end
