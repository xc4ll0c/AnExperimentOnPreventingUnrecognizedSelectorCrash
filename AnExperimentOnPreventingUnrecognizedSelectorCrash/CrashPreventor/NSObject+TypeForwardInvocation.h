//
//  NSObject+TypeForwardInvocation.h
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (TypeForwardInvocation)
+ (void)TFI_startUnrecognizedSelectorProtection;
+ (void)TFI_stopUnrecognizedSelectorProtection;
@end
