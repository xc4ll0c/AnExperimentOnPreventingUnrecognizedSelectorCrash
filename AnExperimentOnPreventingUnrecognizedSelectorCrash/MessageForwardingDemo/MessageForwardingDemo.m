//
//  MessageForwardingDemo.m
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/14.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import "MessageForwardingDemo.h"

@implementation A
- (NSString *)aMethod {
    return @"From Class A";
}
@end

@implementation B
- (NSString *)bMethod {
    return @"From Class B";
}
@end

@interface AB ()
@property (nonatomic, strong) A *a;
@property (nonatomic, strong) B *b;
@end

@implementation AB

- (instancetype)init {
    self = [super init];
    if (self) {
        _a = [[A alloc] init];
        _b = [[B alloc] init];
    }
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    // aMethod利用forwardingTargetForSelector：转发
    if ([self.a respondsToSelector:aSelector]) {
        return self.a;
    } else {
       return [super forwardingTargetForSelector:aSelector];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    // bMethod利用methodSignatureForSelector:响应
    NSMethodSignature *sig = [self.b methodSignatureForSelector:aSelector];
    if (!sig) {
        sig = [super methodSignatureForSelector:aSelector];
    }
    return sig;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([self.b respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:self.b];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

@end
