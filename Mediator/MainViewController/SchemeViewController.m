//
//  SchemeViewController.m
//  Mediator
//
//  Created by Joseph Koh on 12/12/2017.
//  Copyright © 2017 Joseph. All rights reserved.
//

#import "SchemeViewController.h"

@interface SchemeViewController ()

@end

@implementation SchemeViewController

+ (void)load {
    [self mapName:@"schemeDemoPage" withParams:@{
                                           @"id": @"mid",
                                           @"name": @"title"
                                           }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"----%@", self.mid);
}

- (IBAction)OpenWithMapString:(id)sender {
    [YSMediator openURL:@"com.ysmediator.test:///schemeDemoPage?id=88888&name=Test"];
}

- (IBAction)openLink:(id)sender {
    [YSMediator openURL:@"https://www.baidu.com"];
}

@end
