//
//  NSObject+TypeForwardInvocation.m
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import "NSObject+TypeForwardInvocation.h"
#import "NSObject+RuntimeAdditions.h"
#import <objc/runtime.h>
#import "CPThreadSafeCounter.h"

id _tfi_unrecognized_default_imp_(id self, SEL sel) {
    return nil;
}

#pragma mark - _TFI_ForwradingClass
@interface _TFI_ForwradingClass : NSObject
- (id)dummyMethod;
@end

@implementation _TFI_ForwradingClass
- (id)dummyMethod {
    return nil;
}
@end


#pragma mark - TypeForwardInvocation
@implementation NSObject (TypeForwardInvocation)

+ (void)TFI_startUnrecognizedSelectorProtection {
    [self TFI_exchangeMethodSignatureForSelectorMethod];
    [self TFI_exchangeForwardInvocationMethod];
}

+ (void)TFI_stopUnrecognizedSelectorProtection {
    [self TFI_exchangeMethodSignatureForSelectorMethod];
    [self TFI_exchangeForwardInvocationMethod];
}

+ (void)TFI_exchangeMethodSignatureForSelectorMethod {
    [[self class] ra_swizzleInstanceMethodWithOriginalSEL:@selector(methodSignatureForSelector:)
                                              swizzledSEL:@selector(TFI_methodSignatureForSelector:)];
}

+ (void)TFI_exchangeForwardInvocationMethod {
    [[self class] ra_swizzleInstanceMethodWithOriginalSEL:@selector(forwardInvocation:)
                                              swizzledSEL:@selector(TFI_forwardInvocation:)];
}

- (NSMethodSignature *)TFI_methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sig = [self TFI_methodSignatureForSelector:aSelector];
    
    // 若子类已经重写，避免干扰子类的流程，直接返回NSObject的实现
    if ([[self class] ra_isMethodOveridedNSObjectImplementationForSelector:@selector(methodSignatureForSelector:) isClassMethod:NO]) {
        return sig;
    }
    
    if (!sig) {
        // 标记原来的类未针对aSelector实现转发，返回一个默认的sig
        CPThreadSafeCounter *counter = [self TFI_unrecognizedSelectorCacheSet];
        if (!counter) {
            counter = [[CPThreadSafeCounter alloc] init];
            [self TFI_setUnrecognizedSelectorCacheSet:counter];
        }
        [counter addCountForObject:NSStringFromSelector(aSelector)];
        
        sig = [_TFI_ForwradingClass instanceMethodSignatureForSelector:@selector(dummyMethod)];
    }
    return sig;
}

- (void)TFI_forwardInvocation:(NSInvocation *)anInvocation {
    SEL aSelector = [anInvocation selector];
    
    // 判断原来的类中是否实现了转发
    CPThreadSafeCounter *counter = [self TFI_unrecognizedSelectorCacheSet];
    if ([counter isZeroCountForObject:NSStringFromSelector(aSelector)]) {
        [self TFI_forwardInvocation:anInvocation];
    } else {
        // 添加个空方法，然后发起调用
        class_addMethod([_TFI_ForwradingClass class], aSelector, (IMP)_tfi_unrecognized_default_imp_, "@@:");
        [anInvocation invokeWithTarget:[[_TFI_ForwradingClass alloc] init]];
        [counter decreaseCountForObject:NSStringFromSelector(aSelector)];
    }
}


#pragma mark -  Getter & Setter
- (void)TFI_setUnrecognizedSelectorCacheSet:(CPThreadSafeCounter *)set {
    objc_setAssociatedObject(self, @selector(TFI_unrecognizedSelectorCacheSet), set, OBJC_ASSOCIATION_RETAIN);
}

- (id)TFI_unrecognizedSelectorCacheSet {
    return objc_getAssociatedObject(self, _cmd);
}

@end
