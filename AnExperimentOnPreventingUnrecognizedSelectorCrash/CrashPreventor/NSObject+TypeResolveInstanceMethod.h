//
//  NSObject+TypeResolveInstanceMethod.h
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (TypeResolveInstanceMethod)
+ (void)TRIM_startUnrecognizedSelectorProtection;
+ (void)TRIM_stopUnrecognizedSelectorProtection;
@end
