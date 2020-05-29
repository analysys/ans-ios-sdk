//
//  ANSObjectSerializer.m
//  AnalysysAgent
//
//  Created by analysys on 2018/4/9.
//  Copyright © 2018年 analysys. All rights reserved.
//
//  Copyright (c) 2014 Mixpanel. All rights reserved.

#import "ANSObjectSerializer.h"

#import <objc/runtime.h>
#import "NSInvocation+ANSHelper.h"

#import "ANSClassDescription.h"
#import "ANSEnumDescription.h"
#import "ANSObjectIdentityProvider.h"
#import "ANSObjectSerializerConfig.h"
#import "ANSObjectSerializerContext.h"
#import "ANSPropertyDescription.h"
#import "ANSUtil.h"

@implementation ANSObjectSerializer {
    ANSObjectSerializerConfig *_configuration;
    ANSObjectIdentityProvider *_objectIdentityProvider;
    BOOL _isPrePageElement;    //  标识是否当前图层信息
}

- (instancetype)initWithConfiguration:(ANSObjectSerializerConfig *)configuration objectIdentityProvider:(ANSObjectIdentityProvider *)objectIdentityProvider {
    self = [super init];
    if (self) {
        _configuration = configuration;
        _objectIdentityProvider = objectIdentityProvider;
    }
    
    return self;
}

/** 获取上传信息 */
- (NSDictionary *)serializedObjectsWithRootObject:(id)rootObject {
    NSParameterAssert(rootObject != nil);
    
    ANSObjectSerializerContext *context = [[ANSObjectSerializerContext alloc] initWithRootObject:rootObject];
    //  每次随机获取未访问过的对象
    while ([context hasUnvisitedObjects]) {
        [self visitObject:[context dequeueUnvisitedObject] withContext:context];
    }
    
    return @{
        @"objects": [context allSerializedObjects],
        @"rootObject": [_objectIdentityProvider identifierForObject:rootObject]
    };
}


/** 获取当前对象所有属性信息，组成单个结构层 */
- (void)visitObject:(NSObject *)object withContext:(ANSObjectSerializerContext *)context {
    NSParameterAssert(object != nil);
    NSParameterAssert(context != nil);
    //  NSLog(@"-----------log:当前控件：%@--------------",object);
    
    [context addVisitedObject:object];
    
    _isPrePageElement = NO;
    
    NSMutableDictionary *propertyValues = [NSMutableDictionary dictionary];
    //  当前对象类的配置描述信息
    ANSClassDescription *classDescription = [self classDescriptionForObject:object];
    //  NSLog(@"log:当前控件名称：%@",classDescription.name);
    if (classDescription) {
        //  遍历获取类中属性值
        for (ANSPropertyDescription *propertyDescription in [classDescription propertyDescriptions]) {
            //  根据配置 对象是否允许获取
            if ([propertyDescription shouldReadPropertyValueForObject:object]) {
                id propertyValue = [self propertyValueForObject:object withPropertyDescription:propertyDescription context:context];
                if (_isPrePageElement) {
                    break;
                }
                
                propertyValues[propertyDescription.name] = propertyValue ?: [NSNull null];
            }
        }
    }
    
    //  当前视图在父视图中 同类型控件的索引值（计算path使用）
    NSInteger indexOfSuperView = -1;
    if ([object isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)object;
        UIView *superView = [view superview];
        if (superView) {
            NSArray *subviews = [superView subviews];
            NSMutableArray *tmpArray = [NSMutableArray array];
            for (id subView in subviews) {
                if ([subView isKindOfClass:[object class]]) {
                    [tmpArray addObject:subView];
                }
            }
            if ([tmpArray containsObject:object]) {
                indexOfSuperView = [tmpArray indexOfObject:object];
            }
        }
    }
    
    //  若不是上一界面元素，则添加
    if (!_isPrePageElement) {
        NSMutableArray *delegateMethods = [NSMutableArray array];
        id delegate;
        SEL delegateSelector = @selector(delegate);
        
        if ([classDescription delegateInfos].count > 0 && [object respondsToSelector:delegateSelector]) {
            delegate = ((id (*)(id, SEL))[object methodForSelector:delegateSelector])(object, delegateSelector);
            for (ANSDelegateInfo *delegateInfo in [classDescription delegateInfos]) {
                if ([delegate respondsToSelector:NSSelectorFromString(delegateInfo.selectorName)]) {
                    [delegateMethods addObject:delegateInfo.selectorName];
                }
            }
        }
        
        NSDictionary *serializedObject = @{
            @"id": [_objectIdentityProvider identifierForObject:object],
            @"class": [self classHierarchyArrayForObject:object],
            @"properties": propertyValues,
            @"indexOfSuperView": [NSNumber numberWithInteger:indexOfSuperView],
            @"delegate": @{
                    @"class": delegate ? NSStringFromClass([delegate class]) : @"",
                    @"selectors": delegateMethods
            }
        };
        
        [context addSerializedObject:serializedObject];
    }
}

/** 获取当前object 类的继承关系 */
- (NSArray *)classHierarchyArrayForObject:(NSObject *)object {
    NSMutableArray *classHierarchy = [NSMutableArray array];
    
    Class aClass = [object class];
    while (aClass) {
        [classHierarchy addObject:NSStringFromClass(aClass)];
        aClass = [aClass superclass];
    }
    
    return [classHierarchy copy];
}

/** 当前type的所有枚举值 */
- (NSArray *)allValuesForType:(NSString *)typeName {
    NSParameterAssert(typeName != nil);
    
    ANSTypeDescription *typeDescription = [_configuration typeWithName:typeName];
    if ([typeDescription isKindOfClass:[ANSEnumDescription class]]) {
        ANSEnumDescription *enumDescription = (ANSEnumDescription *)typeDescription;
        return [enumDescription allValues];
    }
    
    return @[];
}

/** 根据当前选择器参数 type 获取所对应的服务器配置enums中所有枚举 */
- (NSArray *)parameterVariationsForPropertySelector:(ANSPropertySelectorDescription *)selectorDescription {
    NSAssert(selectorDescription.parameters.count <= 1, @"Currently only support selectors that take 0 to 1 arguments.");
    
    NSMutableArray *variations = [NSMutableArray array];
    
    // TODO: write an algorithm that generates all the variations of parameter combinations.
    if (selectorDescription.parameters.count > 0) {
        ANSPropertySelectorParameterDescription *parameterDescription = selectorDescription.parameters[0];
        for (id value in [self allValuesForType:parameterDescription.type]) {
            [variations addObject:@[ value ]];
        }
    } else {
        // An empty array of parameters (for methods that have no parameters).
        [variations addObject:@[]];
    }
    
    return [variations copy];
}

/** 使用runtime方式获取属性值(使用指针) */
- (id)instanceVariableValueForObject:(id)object propertyDescription:(ANSPropertyDescription *)propertyDescription {
    NSParameterAssert(object != nil);
    NSParameterAssert(propertyDescription != nil);
    
    Ivar ivar = class_getInstanceVariable([object class], [propertyDescription.name UTF8String]);
    if (ivar) {
        const char *objCType = ivar_getTypeEncoding(ivar);
        
        ptrdiff_t ivarOffset = ivar_getOffset(ivar);
        const void *objectBaseAddress = (__bridge const void *)object;
        const void *ivarAddress = (((const uint8_t *)objectBaseAddress) + ivarOffset);
        
        switch (objCType[0])
        {
            case _C_ID:       return object_getIvar(object, ivar);
            case _C_CHR:      return @(*((char *)ivarAddress));
            case _C_UCHR:     return @(*((unsigned char *)ivarAddress));
            case _C_SHT:      return @(*((short *)ivarAddress));
            case _C_USHT:     return @(*((unsigned short *)ivarAddress));
            case _C_INT:      return @(*((int *)ivarAddress));
            case _C_UINT:     return @(*((unsigned int *)ivarAddress));
            case _C_LNG:      return @(*((long *)ivarAddress));
            case _C_ULNG:     return @(*((unsigned long *)ivarAddress));
            case _C_LNG_LNG:  return @(*((long long *)ivarAddress));
            case _C_ULNG_LNG: return @(*((unsigned long long *)ivarAddress));
            case _C_FLT:      return @(*((float *)ivarAddress));
            case _C_DBL:      return @(*((double *)ivarAddress));
            case _C_BOOL:     return @(*((_Bool *)ivarAddress));
            case _C_SEL:      return NSStringFromSelector(*((SEL*)ivarAddress));
            default:
                NSAssert(NO, @"Currently unsupported return type!");
                break;
        }
    }
    
    return nil;
}

/** 使用invocation 方法签名方式获取属性值 */
- (NSInvocation *)invocationForObject:(id)object withSelectorDescription:(ANSPropertySelectorDescription *)selectorDescription {
    NSUInteger __unused parameterCount = selectorDescription.parameters.count;
    
    SEL aSelector = NSSelectorFromString(selectorDescription.selectorName);
    NSAssert(aSelector != nil, @"Expected non-nil selector!");
    
    NSMethodSignature *methodSignature = [object methodSignatureForSelector:aSelector];
    NSInvocation *invocation = nil;
    
    if (methodSignature) {
        NSAssert(methodSignature.numberOfArguments == (parameterCount + 2), @"Unexpected number of arguments!");
        
        invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        invocation.selector = aSelector;
    }
    return invocation;
}

//  根据对象值信息，获取对象标识或对象转换值
- (id)propertyValue:(id)propertyValue propertyDescription:(ANSPropertyDescription *)propertyDescription context:(ANSObjectSerializerContext *)context {
    if (propertyValue != nil) {
        if ([context isVisitedObject:propertyValue]) {
            //  已处理对象 返回对象标识
            return [_objectIdentityProvider identifierForObject:propertyValue];
        } else if ([self isNestedObjectType:propertyDescription.type]) {
            //  未处理对象，对象类型在配置中，则添加未遍历对象
            //  如 HomeVC 为 UIViewController 类型
            [context enqueueUnvisitedObject:propertyValue];
            //            [self addEnqueueUnvisitedObject:propertyValue withContext:context];
            
            return [_objectIdentityProvider identifierForObject:propertyValue];
        } else if ([propertyValue isKindOfClass:[NSArray class]] || [propertyValue isKindOfClass:[NSSet class]]) {
            //  如subviews子视图
            NSMutableArray *arrayOfIdentifiers = [NSMutableArray array];
            for (id value in propertyValue) {
                if ([context isVisitedObject:value] == NO) {
                    [context enqueueUnvisitedObject:value];
                    //                    [self addEnqueueUnvisitedObject:value withContext:context];
                }
                
                [arrayOfIdentifiers addObject:[_objectIdentityProvider identifierForObject:value]];
            }
            propertyValue = [arrayOfIdentifiers copy];
        }
    }
    //  其他值转换为对应值 如float cgrect值等
    return [propertyDescription.valueTransformer transformedValue:propertyValue];
}

//  处理特殊view，某些父控制器直接添加子控制器view，而未添加自控制器
//- (void)addEnqueueUnvisitedObject:(id)value withContext:(ANSObjectSerializerContext *)context {
//    if ([value isKindOfClass:UIView.class]) {
//        UIView *view = (UIView *)value;
//        if ([view.nextResponder isKindOfClass:UIViewController.class]) {
//            if ([context isVisitedObject:view.nextResponder] == NO) {
//                [context enqueueUnvisitedObject:view.nextResponder];
//            }
//        }
//    }
//}

/** 对象及属性描述信息 -> 属性值 */
- (id)propertyValueForObject:(NSObject *)object withPropertyDescription:(ANSPropertyDescription *)propertyDescription context:(ANSObjectSerializerContext *)context {
    
    NSMutableArray *values = [NSMutableArray array];
    //  获取属性描述中 get 选择器描述
    ANSPropertySelectorDescription *selectorDescription = propertyDescription.getSelectorDescription;
    //   使用kvc获取服务器下发单个控件需要获取的属性值
    //    if ([object isKindOfClass:[UIButton class]]) {
    //        NSLog(@"log:UIButton控件:%@",selectorDescription.selectorName);
    //    }
    if (propertyDescription.useKeyValueCoding) {
        // the "fast" (also also simple) path is to use KVC
        id valueForKey = [object valueForKey:selectorDescription.selectorName];
        //        if ([selectorDescription.selectorName isEqualToString:@"titleForState:"]) {
        //            NSLog(@"log:titleForState");
        //        }
        
        if (![object isKindOfClass:[UIWindow class]]) {
            //  过滤掉堆栈中非当前页面数据
            if ([propertyDescription.name isEqualToString:@"window"] && valueForKey == nil) {
                // NSLog(@"log:window属性为nil，%@",object);
                _isPrePageElement = YES;
                return nil;
            }
        }
        //  转换值类型
        id value = [self propertyValue:valueForKey
                   propertyDescription:propertyDescription
                               context:context];
        
        if ([selectorDescription.selectorName isEqualToString:@"frame"]) {
            //  将当前相对坐标转换为相对window的坐标
            if ([value isKindOfClass:[NSDictionary class]]) {
                UIWindow *window = [ANSUtil currentKeyWindow];
                UIView *view = (UIView *)object;
                CGRect absoluteRect = [view convertRect:view.bounds toView:window];

                if (absoluteRect.origin.x < -MAXFLOAT || absoluteRect.origin.y < -MAXFLOAT) {
                    //NSLog(@"---数据不在当前window中--%@", NSStringFromCGPoint(absoluteRect.origin));
                    _isPrePageElement = YES;
                    return nil;
                }

                value[@"AX"] = [NSNumber numberWithFloat:absoluteRect.origin.x];
                value[@"AY"] = [NSNumber numberWithFloat:absoluteRect.origin.y];
            }
        }
        
        NSDictionary *valueDictionary = @{
            @"value": (value ?: [NSNull null])
        };
        
        [values addObject:valueDictionary];
    } else if (propertyDescription.useInstanceVariableAccess) {
        //  使用runtime获取类中的变量值
        id valueForIvar = [self instanceVariableValueForObject:object propertyDescription:propertyDescription];
        //  转换值类型
        id value = [self propertyValue:valueForIvar
                   propertyDescription:propertyDescription
                               context:context];
        
        NSDictionary *valueDictionary = @{
            @"value": (value ?: [NSNull null])
        };
        
        [values addObject:valueDictionary];
    } else {
        //  使用NSInvocation方法签名方式获取属性值
        // the "slow" NSInvocation path. Required in order to invoke methods that take parameters.
        NSInvocation *invocation = [self invocationForObject:object withSelectorDescription:selectorDescription];
        if (invocation) {
            //  获取当前选择器参数类型枚举值
            NSArray *parameterVariations = [self parameterVariationsForPropertySelector:selectorDescription];
            //  获取枚举每个状态下的值
            for (NSArray *parameters in parameterVariations) {
                [invocation ansSetArgumentsFromArray:parameters];
                [invocation invokeWithTarget:object];
                //  调用获取返回值
                id returnValue = [invocation ansReturnValue];
                //  转换值类型
                id value = [self propertyValue:returnValue
                           propertyDescription:propertyDescription
                                       context:context];
                
                NSDictionary *valueDictionary = @{
                    @"where": @{ @"parameters": parameters },
                    @"value": (value ?: [NSNull null])
                };
                
                [values addObject:valueDictionary];
            }
        }
    }
    
    return @{@"values": values};
}

- (BOOL)isNestedObjectType:(NSString *)typeName {
    return [_configuration classWithName:typeName] != nil;
}

/**  循环获取object对应对应的类的描述信息，若当前对应不存在，则遍历其父类（通过类型匹配服务器下发 classes 所对应的属性信息） */
- (ANSClassDescription *)classDescriptionForObject:(NSObject *)object {
    NSParameterAssert(object != nil);
    
    Class aClass = [object class];
    while (aClass != nil) {
        ANSClassDescription *classDescription = [_configuration classWithName:NSStringFromClass(aClass)];
        if (classDescription) {
            return classDescription;
        }
        
        aClass = [aClass superclass];
    }
    
    return nil;
}






@end
