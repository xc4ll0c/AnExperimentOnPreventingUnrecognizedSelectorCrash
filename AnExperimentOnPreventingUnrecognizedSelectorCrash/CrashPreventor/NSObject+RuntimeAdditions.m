//
//  NSObject+RuntimeAdditions.m
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import "NSObject+RuntimeAdditions.h"
#import <objc/runtime.h>

@implementation NSObject (RuntimeAdditions)
+ (void)ra_swizzleClassMethodWithOriginalSEL:(SEL)originalSEL swizzledSEL:(SEL)swizzledSEL {
    Class cls = object_getClass(self);
    
    Method originalMethod = class_getClassMethod(cls, originalSEL);
    Method swizzledMethod = class_getClassMethod(cls, swizzledSEL);
    
    [self ra_swizzleMethodWithOriginalSEL:originalSEL
                           originalMethod:originalMethod
                              swizzledSEL:swizzledSEL
                           swizzledMethod:swizzledMethod
                                    class:cls];
}

+ (void)ra_swizzleInstanceMethodWithOriginalSEL:(SEL)originalSEL swizzledSEL:(SEL)swizzledSEL {
    Method originalMethod = class_getInstanceMethod(self, originalSEL);
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSEL);
    
    [self ra_swizzleMethodWithOriginalSEL:originalSEL
                           originalMethod:originalMethod
                              swizzledSEL:swizzledSEL
                           swizzledMethod:swizzledMethod
                                    class:self];
}

+ (void)ra_swizzleMethodWithOriginalSEL:(SEL)originalSEL
                         originalMethod:(Method)originalMethod
                            swizzledSEL:(SEL)swizzledSEL
                         swizzledMethod:(Method)swizzledMethod
                                  class:(Class)cls {
    BOOL isMethodExists = !class_addMethod(cls, originalSEL, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (isMethodExists) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    } else {
        class_replaceMethod(cls, swizzledSEL, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
}

+ (BOOL)ra_isMethodOveridedNSObjectImplementationForSelector:(SEL)aSelector isClassMethod:(BOOL)isClassMethod {
    Method subclassMethod = nil;
    Method nsojectMethod  = nil;
    
    if (isClassMethod) {
        subclassMethod = class_getClassMethod([self class], aSelector);
        nsojectMethod = class_getClassMethod([NSObject class], aSelector);
    } else {
        subclassMethod = class_getInstanceMethod([self class], aSelector);
        nsojectMethod = class_getInstanceMethod([NSObject class], aSelector);
    }
    
    
    
    IMP subclassImplementation = method_getImplementation(subclassMethod);
    IMP nsojectImplementation = method_getImplementation(nsojectMethod);
    return subclassImplementation != nsojectImplementation;
}
@end
