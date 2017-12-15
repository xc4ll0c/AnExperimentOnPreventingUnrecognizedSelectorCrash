//
//  CPThreadSafeSet.m
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import "CPThreadSafeCounter.h"

@interface CPThreadSafeCounter ()
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMutableDictionary *dict;
@end

@implementation CPThreadSafeCounter
- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        _dict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addCountForObject:(NSString *)object {
    if (object == nil) {
        return;
    }
    [_lock lock];
    NSInteger count = [[_dict objectForKey:object] ?: @0 integerValue];
    [_dict setObject:@(count + 1) forKey:object];
    [_lock unlock];
}

- (BOOL)isZeroCountForObject:(NSString *)anObject {
    BOOL ret = false;
    [_lock lock];
    NSInteger count = [[_dict objectForKey:anObject] ?: @0 integerValue];
    NSAssert(count >= 0, @"计数不能小于0");
    ret = count <= 0;
    [_lock unlock];
    return ret;
}

- (void)decreaseCountForObject:(NSString *)object {
    [_lock lock];
    NSInteger count = [[_dict objectForKey:object] ?: @0 integerValue];
    count = MAX(0, count - 1);
    [_dict setObject:@(count) forKey:object];
    [_lock unlock];
}
@end
