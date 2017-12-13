//
//  NSObject+TypeResolveInstanceMethod.m
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import "NSObject+TypeResolveInstanceMethod.h"
#import "NSObject+RuntimeAdditions.h"
#import <objc/runtime.h>
#import "CPThreadSafeSet.h"


void _trim_unrecognized_default_imp_(id self, SEL sel) {
    
}

#pragma mark - TypeResolveInstanceMethod
@implementation NSObject (TypeResolveInstanceMethod)
+ (void)TRIM_startUnrecognizedSelectorProtection {
    [self TRIM_exchangeResolveInstanceMethodMethod];
}

+ (void)TRIM_stopUnrecognizedSelectorProtection {
    [self TRIM_exchangeResolveInstanceMethodMethod];
}

+ (void)TRIM_exchangeResolveInstanceMethodMethod {
    [[self class] ra_swizzleClassMethodWithOriginalSEL:@selector(resolveInstanceMethod:) swizzledSEL:@selector(TRIM_resolveInstanceMethod:)];
}

+ (BOOL)TRIM_resolveInstanceMethod:(SEL)sel {
    
    // methodSignatureForSelector: 在找不到方法现实时会调用resolveInstanceMethod：获取方法实现
    // 所以在resolveInstanceMethod：直接调用methodSignatureForSelector：会造成死循环调用
    // 是否进入了循环调用，返回NO，破除循环调用
    if ([self TRIM_isInRecusiveCallForSelector:sel]) {
        return NO;
    }
    
    // 先判断类是否已经实现了resolveInstanceMethod转发流程
    BOOL isResolved = [self TRIM_resolveInstanceMethod:sel];
    
    // 判断类是否通过forwardingTargetForSelector:实现了转发流程
    if (!isResolved) {
        id forwardingTarget = [self forwardingTargetForSelector:sel];
        isResolved = forwardingTarget != nil;
    }

    // 判断类是否通过forwardInvocation:实现了转发流程
    if (!isResolved) {
        [self TRIM_markRecusiveCallStartForSelector:sel];
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
        [self TRIM_unmarkRecusiveCallStartForSelector:sel];
        isResolved = sig != nil;
    }
    
    // 此类未实现任何转发流程，则开启防护措施
    if (!isResolved) {
        // 动态添加一个实现
        class_addMethod([self class], sel, (IMP)_trim_unrecognized_default_imp_, "v@:");
        return YES;
    }
    return isResolved;
}

+ (NSCache *)TRIM_SharedCache {
    static __strong NSCache *aCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        aCache = [[NSCache alloc] init];
    });
    return aCache;
}

+ (CPThreadSafeSet *)TRIM_ClassSharedSet {
    NSCache *aCache = [self TRIM_SharedCache];
    NSString *key = NSStringFromClass(self);
    CPThreadSafeSet *set = [aCache objectForKey:key];
    if (!set) {
        set = [[CPThreadSafeSet alloc] init];
        [aCache setObject:set forKey:key];
    }
    return set;
}

+ (BOOL)TRIM_isInRecusiveCallForSelector:(SEL)aSelector {
    CPThreadSafeSet *set = [self TRIM_ClassSharedSet];
    return [set containsObject:NSStringFromSelector(aSelector)];
}

+ (void)TRIM_markRecusiveCallStartForSelector:(SEL)aSelector {
    CPThreadSafeSet *set = [self TRIM_ClassSharedSet];
    [set addObject:NSStringFromSelector(aSelector)];
}

+ (void)TRIM_unmarkRecusiveCallStartForSelector:(SEL)aSelector {
    CPThreadSafeSet *set = [self TRIM_ClassSharedSet];
    [set removeObject:NSStringFromSelector(aSelector)];
}


@end
