//
//  MainViewController.m
//  Mediator
//
//  Created by Joseph Koh on 11/12/2017.
//  Copyright © 2017 Joseph. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()<UITableViewDelegate>

@end

@implementation MainViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [YSMediator pushToViewController:@"LocalViewController"
                              withParams:@{
                                           @"title": @"localDemo",
                                           @"idx": @1
                                           }
                                animated:YES
                                callBack:NULL];
    }
    else if (indexPath.row == 1) {
        [YSMediator pushToViewController:@"schemeDemoPage"
                              withParams:@{@"title": @"SchemeDemo"}
                                animated:YES
                                callBack:^{
                                    NSLog(@"push finish");
                                }];
    }
}


@end
