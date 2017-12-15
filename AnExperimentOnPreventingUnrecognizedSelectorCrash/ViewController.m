//
//  ViewController.m
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import "ViewController.h"
#import "MessageForwardingDemo.h"

@interface ViewController ()
- (void)aVoidMethod;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 运行单元测试时请勿开启
//    [self aVoidMethod];
//    [self messageForwardingDemo];
}

- (void)messageForwardingDemo {
    
    AB *ab = [[AB alloc] init];
    NSLog(@"AB responds to aMethod ? %@", [ab respondsToSelector:@selector(aMethod)] ? @"YES" : @"NO");
    NSLog(@"AB responds to bMethod ? %@", [ab respondsToSelector:@selector(bMethod)] ? @"YES" : @"NO");
    
    NSLog(@"result of sending aMethod to AB: %@", [ab aMethod]);
    NSLog(@"result of sending bMethod to AB: %@", [ab bMethod]);
    NSLog(@"mark end");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
