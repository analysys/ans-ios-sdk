//
//  ANSEventBinding.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSEventBinding.h"

#import "ANSVisualSDK.h"
#import "ANSUIControlBinding.h"
#import "ANSUITableViewBinding.h"
#import "AnalysysLogger.h"

@implementation ANSEventBinding


+ (ANSEventBinding *)bindingWithJSONObject:(NSDictionary *)object
{
    if (object == nil) {
        ANSDebug(@"must supply an JSON object to initialize from");
        return nil;
    }
    
    NSString *bindingType = object[@"event_type"];
    Class klass = [self subclassFromString:bindingType];
    return [klass bindingWithJSONObject:object];
}

+ (ANSEventBinding *)bindngWithJSONObject:(NSDictionary *)object
{
    return [self bindingWithJSONObject:object];
}

+ (Class)subclassFromString:(NSString *)bindingType
{
    NSDictionary *classTypeMap = @{
                                   [ANSUIControlBinding typeName]: [ANSUIControlBinding class],
                                   [ANSUITableViewBinding typeName]: [ANSUITableViewBinding class]
                                   };
    return [classTypeMap valueForKey:bindingType] ?: [ANSUIControlBinding class];
}

+ (void)trackObject:(id)object withEventBinding:(ANSEventBinding *)eventBinding
{
    [[ANSVisualSDK sharedManager] trackObject:object withEvent:eventBinding.eventName];
}

- (instancetype)initWithEventBindingInfo:(NSDictionary *)bindingInfo
{
    if (self = [super init]) {
        self.eventName = bindingInfo[@"event_id"];
        self.path = [[ANSObjectSelector alloc] initWithPathString:bindingInfo[@"path"]];
        self.name = [[NSUUID UUID] UUIDString];
        self.running = NO;
        self.matchText = bindingInfo[@"match_text"];
        self.targetPage = bindingInfo[@"target_page"];
        self.bindingInfo = bindingInfo;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Event Binding base class: '%@' for '%@'", [self eventName], [self path]];
}

#pragma mark -- Method stubs

+ (NSString *)typeName
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)executeVisualEventBinding
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)stop
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark - 编码解码

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.ID = [[aDecoder decodeObjectForKey:@"ID"] unsignedLongValue];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        NSString *pathString = [aDecoder decodeObjectForKey:@"path"];
        self.path = [[ANSObjectSelector alloc] initWithPathString:pathString];
        self.eventName = [aDecoder decodeObjectForKey:@"eventName"];
        self.swizzleClass = NSClassFromString([aDecoder decodeObjectForKey:@"swizzleClass"]);
        self.matchText = [aDecoder decodeObjectForKey:@"matchText"];
        self.targetPage = [aDecoder decodeObjectForKey:@"targetPage"];
        self.bindingInfo = [aDecoder decodeObjectForKey:@"bindingInfo"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_ID) forKey:@"ID"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_path.pathString forKey:@"path"];
    [aCoder encodeObject:_eventName forKey:@"eventName"];
    [aCoder encodeObject:NSStringFromClass(_swizzleClass) forKey:@"swizzleClass"];
    [aCoder encodeObject:_matchText forKey:@"matchText"];
    [aCoder encodeObject:_targetPage forKey:@"targetPage"];
    [aCoder encodeObject:_bindingInfo forKey:@"bindingInfo"];
}

#pragma mark - 对象比较

/** 重写对象比较方法 */
- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (![other isKindOfClass:[ANSEventBinding class]]) {
        return NO;
    }
    
    return [self.eventName isEqual:((ANSEventBinding *)other).eventName] && [self.path isEqual:((ANSEventBinding *)other).path];
}

/** 重写hash方法 */
- (NSUInteger)hash {
    return [self.eventName hash] ^ [self.path hash];
}


@end
