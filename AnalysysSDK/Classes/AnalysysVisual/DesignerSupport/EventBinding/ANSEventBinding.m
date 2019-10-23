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
#import "ANSConsoleLog.h"

@implementation ANSEventBinding


+ (ANSEventBinding *)bindingWithJSONObject:(NSDictionary *)object
{
    if (object == nil) {
        AnsDebug(@"must supply an JSON object to initialize from");
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

- (instancetype)initWithEventName:(NSString *)eventName
                           onPath:(NSString *)path
                        matchText:(NSString *)matchText
                      bindingInfo:(NSDictionary *)bindingInfo
{
    if (self = [super init]) {
        self.eventName = eventName;
        self.path = [[ANSObjectSelector alloc] initWithString:path];
        self.name = [[NSUUID UUID] UUIDString];
        self.running = NO;
        self.matchText = matchText;
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

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *path = [aDecoder decodeObjectForKey:@"path"];
    NSString *eventName = [aDecoder decodeObjectForKey:@"eventName"];
    NSString *matchText = [aDecoder decodeObjectForKey:@"matchText"];
    NSDictionary *bindingInfo = [aDecoder decodeObjectForKey:@"bindingInfo"];
    if (self = [self initWithEventName:eventName
                                onPath:path
                             matchText:matchText
                           bindingInfo:bindingInfo]) {
        self.ID = [[aDecoder decodeObjectForKey:@"ID"] unsignedLongValue];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.swizzleClass = NSClassFromString([aDecoder decodeObjectForKey:@"swizzleClass"]);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(_ID) forKey:@"ID"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_path.string forKey:@"path"];
    [aCoder encodeObject:_eventName forKey:@"eventName"];
    [aCoder encodeObject:NSStringFromClass(_swizzleClass) forKey:@"swizzleClass"];
    [aCoder encodeObject:_matchText forKey:@"matchText"];
    [aCoder encodeObject:_bindingInfo forKey:@"bindingInfo"];
}

#pragma mark - 对象比较

/** 重写对象比较方法 */
- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![other isKindOfClass:[ANSEventBinding class]]) {
        return NO;
    } else {
        return [self.eventName isEqual:((ANSEventBinding *)other).eventName] && [self.path isEqual:((ANSEventBinding *)other).path];
    }
}

/** 重写hash方法 */
- (NSUInteger)hash {
    return [self.eventName hash] ^ [self.path hash];
}


@end
