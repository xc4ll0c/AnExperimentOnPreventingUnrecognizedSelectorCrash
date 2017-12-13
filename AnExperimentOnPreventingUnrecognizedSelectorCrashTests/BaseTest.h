//
//  BaseTest.h
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZWZCrashPreventor.h"

@interface BaseTest : XCTestCase
- (void)startProtectionWithType:(ZWZCrashPreventorProtectionType)type;
- (void)stopProtection;
@end
