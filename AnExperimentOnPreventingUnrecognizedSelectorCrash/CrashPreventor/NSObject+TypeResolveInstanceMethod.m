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
#import "CPThreadSafeCounter.h"


id _trim_unrecognized_default_imp_(id self, SEL sel) {
    return nil;
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
    
    // 若子类已经重写，避免干扰子类的流程，直接返回NSObject的实现
    if ([[self class] ra_isMethodOveridedNSObjectImplementationForSelector:@selector(resolveInstanceMethod:) isClassMethod:YES]) {
        return isResolved;
    }
    
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

#pragma mark - 信息标记
+ (CPThreadSafeCounter *)TRIM_ClassSharedcounter {
    NSCache *aCache = [self TRIM_SharedCache];
    NSString *key = NSStringFromClass(self);
    CPThreadSafeCounter *counter = [aCache objectForKey:key];
    if (!counter) {
        counter = [[CPThreadSafeCounter alloc] init];
        [aCache setObject:counter forKey:key];
    }
    return counter;
}

+ (BOOL)TRIM_isInRecusiveCallForSelector:(SEL)aSelector {
    CPThreadSafeCounter *counter = [self TRIM_ClassSharedcounter];
    return ![counter isZeroCountForObject:NSStringFromSelector(aSelector)];
}

+ (void)TRIM_markRecusiveCallStartForSelector:(SEL)aSelector {
    CPThreadSafeCounter *counter = [self TRIM_ClassSharedcounter];
    [counter addCountForObject:NSStringFromSelector(aSelector)];
}

+ (void)TRIM_unmarkRecusiveCallStartForSelector:(SEL)aSelector {
    CPThreadSafeCounter *counter = [self TRIM_ClassSharedcounter];
    [counter decreaseCountForObject:NSStringFromSelector(aSelector)];
}


@end
