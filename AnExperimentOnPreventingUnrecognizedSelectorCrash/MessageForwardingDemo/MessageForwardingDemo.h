//
//  MessageForwardingDemo.h
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/14.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A : NSObject
- (NSString *)aMethod;
@end

@interface B : NSObject
- (NSString *)bMethod;
@end

@interface AB : NSObject
- (NSString *)aMethod;
- (NSString *)bMethod;
@end
