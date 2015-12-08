//
//  Toast.m
//  qizishibie
//
//  Created by ll on 11/21/15.
//  Copyright © 2015 ll. All rights reserved.
//

#import "Toast.h"
#import "MBProgressHUD.h"

@implementation Toast

+ (void) toast:(NSString *)toastStr
          view:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = toastStr;
    
    dispatch_async(dispatch_queue_create("toast Q", NULL), ^{
        [NSThread sleepForTimeInterval:1.0f];
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.hidden = YES;
        });
    });
}

@end
