//
//  RootView.m
//  testweiqi
//
//  Created by ll on 12/1/15.
//  Copyright © 2015 ll. All rights reserved.
//

#import "RootView.h"

static CGFloat gridlen = 38.0;

@implementation RootView


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat r = gridlen/2;
    
    CGContextSetFillColor(context, CGColorGetComponents( [[UIColor colorWithRed:0
                                                                          green:0
                                                                           blue:0
                                                                          alpha:1 ] CGColor]));
    CGFloat x = self.frame.size.height+38;
    CGFloat y1 = 60 + 40 + 30 + 40 + 100;
    CGContextAddArc(context, x, y1, r, 0, M_PI*2, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    CGContextSetFillColor(context, CGColorGetComponents( [[UIColor colorWithRed:255
                                                                          green:255
                                                                           blue:255
                                                                          alpha:1 ] CGColor]));
    CGFloat y2 = y1 + 70;
    CGContextAddArc(context, x, y2, r, 0, M_PI*2, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
}


@end
