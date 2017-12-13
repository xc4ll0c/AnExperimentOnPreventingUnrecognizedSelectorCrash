//
//  ZWZCrashPreventor.m
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import "ZWZCrashPreventor.h"
#import "NSObject+TypeResolveInstanceMethod.h"
#import "NSObject+TypeForwardingTarget.h"
#import "NSObject+TypeForwardInvocation.h"

@interface ZWZCrashPreventor ()
@property (nonatomic, assign) ZWZCrashPreventorProtectionType type;
@property (nonatomic, assign) BOOL isProtecting;
@end

@implementation ZWZCrashPreventor

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static __strong ZWZCrashPreventor *_preventor = nil;
    dispatch_once(&onceToken, ^{
        _preventor = [[ZWZCrashPreventor alloc] init];
    });
    return _preventor;
}

- (void)startProtectionWithType:(ZWZCrashPreventorProtectionType)type {
    if (self.isProtecting) {
        if (self.type == type) {
            return;
        } else {
            [self stopProtection];
        }
    }
    
    self.type = type;
    switch (self.type) {
        case ZWZCPPTypeResolveInstanceMethod:
            [NSObject TRIM_startUnrecognizedSelectorProtection];
            break;
            
        case ZWZCPPTypeForwardingTarget:
            [NSObject TFT_startUnrecognizedSelectorProtection];
            break;
            
        case ZWZCPPTypeForwardInvocation:
            [NSObject TFI_startUnrecognizedSelectorProtection];
            break;
    }
    self.isProtecting = YES;
}

- (void)stopProtection {
    if (!self.isProtecting) return;
    switch (self.type) {
        case ZWZCPPTypeResolveInstanceMethod:
            [NSObject TRIM_stopUnrecognizedSelectorProtection];
            break;
            
        case ZWZCPPTypeForwardingTarget:
            [NSObject TFT_stopUnrecognizedSelectorProtection];
            break;
            
        case ZWZCPPTypeForwardInvocation:
            [NSObject TFI_stopUnrecognizedSelectorProtection];
            break;
    }
    self.isProtecting = NO;
}


@end
