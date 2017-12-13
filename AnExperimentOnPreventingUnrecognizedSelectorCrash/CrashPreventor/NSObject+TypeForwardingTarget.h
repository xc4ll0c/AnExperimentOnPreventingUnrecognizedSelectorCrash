//
//  NSObject+TypeForwardingTarget.h
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (TypeForwardingTarget)
+ (void)TFT_startUnrecognizedSelectorProtection;
+ (void)TFT_stopUnrecognizedSelectorProtection;
@end
