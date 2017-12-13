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

void _trim_unrecognized_default_imp_(id self, SEL sel) {
}

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
    
    // 先判断类是否已经实现了resolveInstanceMethod转发流程
    BOOL isResolved = [self TRIM_resolveInstanceMethod:sel];
    
    // 判断类是否通过forwardingTargetForSelector:实现了转发流程
    if (!isResolved) {
        id forwardingTarget = [self forwardingTargetForSelector:sel];
        isResolved = forwardingTarget != nil;
    }
    
    // 判断类是否通过forwardInvocation:实现了转发流程
    if (!isResolved) {
        NSMethodSignature *sig = [self methodSignatureForSelector:sel];
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
@end
