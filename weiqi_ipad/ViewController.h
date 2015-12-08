//
//  ViewController.h
//  testweiqi
//
//  Created by ll on 11/28/15.
//  Copyright © 2015 ll. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QipanView.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet QipanView *qipanViewOutlet;

- (IBAction)resetButtonAction:(id)sender;
- (IBAction)backButtonAction:(id)sender;
//- (IBAction)sendAction:(id)sender;


@property (weak, nonatomic) IBOutlet UILabel *deadWhiteChessCountOutlet;
@property (weak, nonatomic) IBOutlet UILabel *deadBlackChessCountOutlet;
@end

