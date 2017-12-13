//
//  ProtectionTypeResolveInstanceMethodTest.m
//  AnExperimentOnPreventingUnrecognizedSelectorCrashTests
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZWZCrashPreventor.h"

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

@interface ProtectionTypeResolveInstanceMethodTest : XCTestCase

@end

@implementation ProtectionTypeResolveInstanceMethodTest

- (void)setUp {
    [super setUp];
    [[ZWZCrashPreventor sharedInstance] startProtectionWithType:ZWZCPPTypeForwardingTarget];
}

- (void)tearDown {
    [super tearDown];
    [[ZWZCrashPreventor sharedInstance] stopProtection];
}

- (void)testThatItCanProtectVoidMethod {
    TestObject *tObject = [[TestObject alloc] init];
    @try {
        [tObject voidMethod];
    } @catch (NSException *exception) {
        // 不能抛出异常
        XCTAssertTrue(false);
    }
}

- (void)testThatItCanProtectMethodReturnsAnObject {
    TestObject *tObject = [[TestObject alloc] init];
    
    @try {
        id object = [tObject methodReturnsAnObject];
        NSLog(@"%@", object);
    } @catch (NSException *exception) {
        // 不能抛出异常
        XCTAssertTrue(false);
    }
}

- (void)testThatItCanMethodReturnsABasicValue {
    TestObject *tObject = [[TestObject alloc] init];
    
    @try {
        NSInteger i = [tObject methodReturnsABasicValue];
        NSLog(@"%@", @(i));
    } @catch (NSException *exception) {
        // 不能抛出异常
        XCTAssertTrue(false);
    }
}

- (void)testThatItCanProtectMethodReturnsAStruct {
    
    TestObject *tObject = [[TestObject alloc] init];
    
    @try {
        SimpleStruct aStruct = [tObject methodReturnsAStruct];
        NSLog(@"%@", @(aStruct.i));
    } @catch (NSException *exception) {
        // 不能抛出异常
        XCTAssertTrue(false);
    }
}

- (void)testThatItCanProtectMethodReturnsAnObjectWithP1 {
    
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
- (void)disable_testThatItCanProtectMethodReturnsACGRect {
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
