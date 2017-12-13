//
//  CPThreadSafeSet.m
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import "CPThreadSafeSet.h"

@interface CPThreadSafeSet ()
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMutableSet *set;
@end

@implementation CPThreadSafeSet
- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        _set = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)addObject:(NSString *)object {
    [_lock lock];
    [_set addObject:object];
    [_lock unlock];
}

- (BOOL)containsObject:(NSString *)anObject {
    BOOL ret = false;
    [_lock lock];
    ret = [_set containsObject:anObject];
    [_lock unlock];
    return ret;
}

- (void)removeObject:(NSString *)object {
    [_lock lock];
    [_set removeObject:object];
    [_lock unlock];
}
@end
