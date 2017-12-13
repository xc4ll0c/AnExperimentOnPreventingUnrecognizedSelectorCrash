//
//  ViewController.m
//  AnExperimentOnPreventingUnrecognizedSelectorCrash
//
//  Created by Wenzheng Zhang on 2017/12/13.
//  Copyright © 2017年 Wenzheng Zhang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (void)aVoidMethod;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self aVoidMethod];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
