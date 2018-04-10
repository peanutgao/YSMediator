//
//  TwoViewController.m
//  Mediator
//
//  Created by Joseph Koh on 11/12/2017.
//  Copyright © 2017 Joseph. All rights reserved.
//

#import "TwoViewController.h"
#import "YSMediator.h"

@interface TwoViewController ()

@end

@implementation TwoViewController

+ (void)load {
    [self mapName:@"twoVC" withParams:@{@"name": @"title"}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (IBAction)pushToNextViewController:(id)sender {
    [YSMediator pushToViewController:@"OneViewController"
                          withParams:@{
                                       @"name": [NSString stringWithFormat:@"第%zd个页面", self.idx + 1],
                                       @"idx": @(self.idx + 1)
                                       }
                            animated:YES
                            callBack:NULL];
}

- (IBAction)popPreViewController:(id)sender {
    [YSMediator popToViewControllerName:@"../../" animated:YES];
}

- (IBAction)popToRootViewController:(id)sender {
    [YSMediator popToViewControllerName:@"mainVC" animated:YES];
}
@end
