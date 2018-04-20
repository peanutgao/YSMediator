//
//  YSPresentedViewController.m
//  YSMediator_Example
//
//  Created by Joseph Koh on 2018/4/20.
//  Copyright © 2018年 peanutgao. All rights reserved.
//

#import "YSPresentedViewController.h"

@interface YSPresentedViewController ()

@property (weak, nonatomic) IBOutlet UITextField *inputView;

@end

@implementation YSPresentedViewController

+ (void)load {
    [self mapName:@"presentedVC" withParams:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)dismissView:(id)sender {
    if (self.myCallBack) {
        self.myCallBack(self.inputView.text);
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
