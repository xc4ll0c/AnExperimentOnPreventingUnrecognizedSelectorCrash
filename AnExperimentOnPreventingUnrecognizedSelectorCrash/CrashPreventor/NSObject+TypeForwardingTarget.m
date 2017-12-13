//
//  NSObject+TypeForwardingTarget.m
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import "NSObject+TypeForwardingTarget.h"
#import "NSObject+RuntimeAdditions.h"
#import <objc/runtime.h>

char * const _kTFTForwardingTargetClassName = "_kTFTForwardingTargetClassName";

void _tft_unrecognized_default_imp_(id self, SEL sel) {
}

@implementation NSObject (TypeForwardingTarget)
+ (void)TFT_startUnrecognizedSelectorProtection {
    [self TFT_exchangeForwardingTargetForSelectorMethod];
}

+ (void)TFT_stopUnrecognizedSelectorProtection {
    [self TFT_exchangeForwardingTargetForSelectorMethod];
}

+ (void)TFT_exchangeForwardingTargetForSelectorMethod {
    [[self class] ra_swizzleInstanceMethodWithOriginalSEL:@selector(forwardingTargetForSelector:)
                                              swizzledSEL:@selector(TFT_forwardingTargetForSelector:)];
}

- (id)TFT_forwardingTargetForSelector:(SEL)aSelector {
    
    // 检查此类是否通过forwardingTargetForSelector:实现消息转发
    id forwardingTarget = [self TFT_forwardingTargetForSelector:aSelector];
    
    // 检查此类是否通过forwardingTargetForSelector:实现了转发流程
    if (!forwardingTarget) {
        NSMethodSignature *sig = [self methodSignatureForSelector:aSelector];
        if (sig != nil) {
            return forwardingTarget;
        }
    }
    
    // 获取一个转发代理实例
    if (!forwardingTarget) {
        forwardingTarget = [self TFT_instanceOfForwardingTargetClassWithSelector:aSelector];
    }
    
    return forwardingTarget;
}

- (id)TFT_instanceOfForwardingTargetClassWithSelector:(SEL)aSelector {
    Class forwardingTargetClass = objc_getClass(_kTFTForwardingTargetClassName);
    
    if (!forwardingTargetClass) {
        forwardingTargetClass = objc_allocateClassPair([NSObject class], _kTFTForwardingTargetClassName, sizeof([NSObject class]));
        objc_registerClassPair(forwardingTargetClass);
    }
    
    class_addMethod(forwardingTargetClass, aSelector, (IMP)_tft_unrecognized_default_imp_, "v@:");
    id instance = [[forwardingTargetClass alloc] init];
    return instance;
}

@end
