//
//  AppDelegate.m
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import "AppDelegate.h"
#import "ZWZCrashPreventor.h"
#import <objc/runtime.h>

// 动态的实现
void _TestObject_dynamic_imp_(id self, SEL sel) {
}

@interface TestObject : NSObject
- (void)aVoidMethod;
@end

@implementation TestObject
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(aVoidMethod)) {
        class_addMethod([self class], sel, (IMP)_TestObject_dynamic_imp_, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}
@end

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)load {
    // 运行单元测试时请勿开启
//    [[ZWZCrashPreventor sharedInstance] startProtectionWithType:ZWZCPPTypeForwardInvocation];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
