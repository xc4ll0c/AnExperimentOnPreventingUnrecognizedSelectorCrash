//
//  CPThreadSafeSet.h
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPThreadSafeCounter : NSObject
- (void)addCountForObject:(NSString *)object;
- (void)decreaseCountForObject:(NSString *)object;
- (BOOL)isZeroCountForObject:(NSString *)anObject;
@end
