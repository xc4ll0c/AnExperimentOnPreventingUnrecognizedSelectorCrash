//
//  ZWZCrashPreventor.h
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 防护的实现类型

 - ZWZCPPTypeResolveInstanceMethod: 通过替换类方法ResolveInstanceMethod实现防护
 - ZWZCPPTypeForwardingTarget: 通过替换实例方法forwardingTargetForSelector:实现防护
 - ZWZCPPTypeForwardInvocation: 通过替换实例方法forwardInvocation:实现防护
 */
typedef NS_ENUM(NSUInteger, ZWZCrashPreventorProtectionType) {
    ZWZCPPTypeResolveInstanceMethod,
    ZWZCPPTypeForwardingTarget,
    ZWZCPPTypeForwardInvocation,
};

@interface ZWZCrashPreventor : NSObject

/**
 获取单例

 @return ZWZCrashPreventor单例
 */
+ (instancetype)sharedInstance;


/**
 开启保护。⚠️:此方法非线程安全。

 @param type 防护的实现类型
 */
- (void)startProtectionWithType:(ZWZCrashPreventorProtectionType)type;


/**
 关闭保护，⚠️:此方法非线程安全。
 */
- (void)stopProtection;
@end
