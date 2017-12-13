//
//  CPThreadSafeSet.h
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPThreadSafeSet : NSObject
- (void)addObject:(NSString *)object;
- (BOOL)containsObject:(NSString *)anObject;
- (void)removeObject:(NSString *)object;
@end
