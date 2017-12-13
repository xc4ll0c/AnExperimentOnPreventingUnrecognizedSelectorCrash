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


void _tfi_unrecognized_default_imp_(id self, SEL sel) {
}

#pragma mark - _TFI_ForwradingClass
@interface _TFI_ForwradingClass : NSObject
- (void)dummyMethod;
@end

@implementation _TFI_ForwradingClass
- (void)dummyMethod {
}
@end

#pragma mark - _TFI_Set
@interface _TFI_Set : NSObject
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMutableSet *set;

- (void)addObject:(NSString *)object;
- (BOOL)containsObject:(NSString *)anObject;
@end

@implementation _TFI_Set
- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        _set = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)addObject:(NSString *)object {
    [_lock lock];
    [_set addObject:object];
    [_lock unlock];
}

- (BOOL)containsObject:(NSString *)anObject {
    BOOL ret = false;
    [_lock lock];
    ret = [_set containsObject:anObject];
    [_lock unlock];
    return ret;
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
    if (!sig) {
        // 标记原来的类是否实现了转发且返回一个sig
        _TFI_Set *set = [self TFI_unrecognizedSelectorCacheSet];
        if (!set) {
            set = [[_TFI_Set alloc] init];
            [self TFI_setUnrecognizedSelectorCacheSet:set];
        }
        [set addObject:NSStringFromSelector(aSelector)];
        
        sig = [_TFI_ForwradingClass instanceMethodSignatureForSelector:@selector(dummyMethod)];
    }
    return sig;
}

- (void)TFI_forwardInvocation:(NSInvocation *)anInvocation {
    SEL aSelector = [anInvocation selector];
    
    // 判断原来的类中是否实现了转发
    _TFI_Set *set = [self TFI_unrecognizedSelectorCacheSet];
    if (![set containsObject:NSStringFromSelector(aSelector)]) {
        [self TFI_forwardInvocation:anInvocation];
    } else {
        // 添加个空方法，然后发起调用
        class_addMethod([_TFI_ForwradingClass class], aSelector, (IMP)_tfi_unrecognized_default_imp_, "v@:");
        [anInvocation invokeWithTarget:[[_TFI_ForwradingClass alloc] init]];
    }
}


#pragma mark -  Getter & Setter
- (void)TFI_setUnrecognizedSelectorCacheSet:(_TFI_Set *)set {
    objc_setAssociatedObject(self, @selector(TFI_unrecognizedSelectorCacheSet), set, OBJC_ASSOCIATION_RETAIN);
}

- (id)TFI_unrecognizedSelectorCacheSet {
    return objc_getAssociatedObject(self, _cmd);
}

@end
