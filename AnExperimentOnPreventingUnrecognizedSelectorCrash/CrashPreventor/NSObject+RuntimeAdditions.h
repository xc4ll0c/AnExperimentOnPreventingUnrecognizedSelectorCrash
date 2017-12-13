//
//  NSObject+RuntimeAdditions.h
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (RuntimeAdditions)
+ (void)ra_swizzleClassMethodWithOriginalSEL:(SEL)originalSEL swizzledSEL:(SEL)swizzledSEL;
+ (void)ra_swizzleInstanceMethodWithOriginalSEL:(SEL)originalSEL swizzledSEL:(SEL)swizzledSEL;
@end
