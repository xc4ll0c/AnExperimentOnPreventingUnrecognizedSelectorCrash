//
//  BaseTest.m
//  AnExperimentOnPreventingUnrecognizedSelectorCrashTests
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//
#import "BaseTest.h"

struct SimpleStruct {
    NSInteger i;
};

typedef struct SimpleStruct SimpleStruct;


#pragma mark - TestObject
@interface TestObject : NSObject
- (void)voidMethod;
- (id)methodReturnsAnObject;
- (NSInteger)methodReturnsABasicValue;
- (SimpleStruct)methodReturnsAStruct;
- (id)methodReturnsAnObjectWithP1:(id)p1 rect:(CGRect)rect;
- (CGRect)methodReturnsACGRect;
@end

@implementation TestObject
@end

@implementation BaseTest
- (void)testThatProtectionTypeResolveInstanceMethodCanPreventCrash {
    [[ZWZCrashPreventor sharedInstance] startProtectionWithType:ZWZCPPTypeResolveInstanceMethod];
    [self runAllCase];
    [[ZWZCrashPreventor sharedInstance] stopProtection];
}

- (void)testThatProtectionTypeForwardingTargetCanPreventCrash {
    [[ZWZCrashPreventor sharedInstance] startProtectionWithType:ZWZCPPTypeForwardingTarget];
    [self runAllCase];
    [[ZWZCrashPreventor sharedInstance] stopProtection];
}

- (void)testThatProtectionTypeForwardInvocationCanPreventCrash {
    [[ZWZCrashPreventor sharedInstance] startProtectionWithType:ZWZCPPTypeForwardInvocation];
    [self runAllCase];
    [[ZWZCrashPreventor sharedInstance] stopProtection];
}

- (void)runAllCase {
    [self p_testThatItCanProtectVoidMethod];
    [self p_testThatItCanProtectMethodReturnsAnObject];
    [self p_testThatItCanMethodReturnsABasicValue];
    [self p_testThatItCanProtectMethodReturnsAStruct];
    [self p_testThatItCanProtectMethodReturnsAnObjectWithP1];
    
    // 这个方法会崩溃
//    [self p_testThatItCanProtectMethodReturnsACGRect];
}

- (void)p_testThatItCanProtectVoidMethod {
    TestObject *tObject = [[TestObject alloc] init];
    @try {
        [tObject voidMethod];
    } @catch (NSException *exception) {
        // 不能抛出异常
        XCTAssertTrue(false);
    }
}

- (void)p_testThatItCanProtectMethodReturnsAnObject {
    TestObject *tObject = [[TestObject alloc] init];
    @try {
        id object = [tObject methodReturnsAnObject];
        NSLog(@"%@", object);
    } @catch (NSException *exception) {
        // 不能抛出异常
        XCTAssertTrue(false);
    }
}

- (void)p_testThatItCanMethodReturnsABasicValue {
    TestObject *tObject = [[TestObject alloc] init];
    @try {
        NSInteger i = [tObject methodReturnsABasicValue];
        NSLog(@"%@", @(i));
    } @catch (NSException *exception) {
        // 不能抛出异常
        XCTAssertTrue(false);
    }
}

- (void)p_testThatItCanProtectMethodReturnsAStruct {
    TestObject *tObject = [[TestObject alloc] init];
    @try {
        SimpleStruct aStruct = [tObject methodReturnsAStruct];
        NSLog(@"%@", @(aStruct.i));
    } @catch (NSException *exception) {
        // 不能抛出异常
        XCTAssertTrue(false);
    }
}

- (void)p_testThatItCanProtectMethodReturnsAnObjectWithP1 {
    TestObject *tObject = [[TestObject alloc] init];
    @try {
        id object = [tObject methodReturnsAnObjectWithP1:[[NSObject alloc] init]
                                                    rect:CGRectMake(10, 20, 100, 200)];
        NSLog(@"%@", object);
    } @catch (NSException *exception) {
        // 不能抛出异常
        XCTAssertTrue(false);
    }
}

// 这会崩溃
- (void)p_testThatItCanProtectMethodReturnsACGRect {
    TestObject *tObject = [[TestObject alloc] init];
    @try {
        CGRect aStruct = [tObject methodReturnsACGRect];
        NSLog(@"%@", @(aStruct.origin.x));
    } @catch (NSException *exception) {
        // 不能抛出异常
        XCTAssertTrue(false);
    }
}

@end
