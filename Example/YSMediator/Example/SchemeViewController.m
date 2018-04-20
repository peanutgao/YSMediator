//
//  SchemeViewController.m
//  Mediator
//
//  Created by Joseph Koh on 12/12/2017.
//  Copyright © 2017 Joseph. All rights reserved.
//

#import "SchemeViewController.h"

@interface SchemeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation SchemeViewController

+ (void)load {
    [self mapName:@"schemeDemoPage" withParams:@{
                                                 @"mid": @"id",
                                                 @"title": @"name"
                                                 }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.infoLabel.text = [NSString stringWithFormat:@"mid: %@", self.mid];
}

- (IBAction)OpenWithMapString:(id)sender {
    NSString *urlStr = [NSString stringWithFormat:@"com.ysmediator.test:///schemeDemoPage?id=%d&name=MapTest", arc4random_uniform(100)];
    [YSMediator openURL:urlStr withFilter:^BOOL(NSDictionary *params) {
        NSInteger mid = [params[@"id"] intValue];
        if (mid < 50) {
            NSLog(@"mid: %zd, 不满足条件,不允许跳转", mid);
            return NO;
        }
        return YES;
    }];
}

- (IBAction)openLink:(id)sender {
    NSString *urlStr = @"https://www.baidu.com";
    [YSMediator openURL:urlStr];
}
- (IBAction)popToRoot:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
