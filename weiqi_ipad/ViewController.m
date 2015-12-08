//
//  ViewController.m
//  testweiqi
//
//  Created by ll on 11/28/15.
//  Copyright © 2015 ll. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeadChessCount:) name:@"updateDeadChessCount" object:nil];
}

- (void) updateDeadChessCount:(NSNotification *)notification
{
    id obj = [notification object];

    self.deadWhiteChessCountOutlet.text = [NSString stringWithFormat:@"%@", obj[0]];
    self.deadBlackChessCountOutlet.text = [NSString stringWithFormat:@"%@", obj[1]];
}

- (IBAction)resetButtonAction:(id)sender {
    [self.qipanViewOutlet reset];
}

- (IBAction)backButtonAction:(id)sender {
    [self.qipanViewOutlet back];
}

//- (IBAction)sendAction:(id)sender {
//    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"是否确定发送？"
//                                                                   message:nil
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    
//    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"取消"
//                                                      style:UIAlertActionStyleDefault
//                                                    handler:^(UIAlertAction * action) {}];
//    
//    UIAlertAction* confirm = [UIAlertAction actionWithTitle:@"发送"
//                                                            style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action) {}];
//    
//    [alert addAction:cancel];
//    [alert addAction:confirm];
//    [self presentViewController:alert animated:YES completion:nil];
//}


@end
