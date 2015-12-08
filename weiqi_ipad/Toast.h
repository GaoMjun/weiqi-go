//
//  Toast.h
//  qizishibie
//
//  Created by ll on 11/21/15.
//  Copyright © 2015 ll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Toast : NSObject

+ (void) toast:(NSString *)toastStr
          view:(UIView *)view;

@end
