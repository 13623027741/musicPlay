//
//  LineCircleView.m
//  MusicPlay
//
//  Created by kaidan on 16/5/24.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import "LineCircleView.h"

@implementation LineCircleView

-(void)drawRect:(CGRect)rect{
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat x = rect.size.width / 2;
    CGFloat y = rect.size.height / 2;
    CGContextAddArc(context, x, y, x - 5, 0, M_PI * 2, 1);
    CGContextSetLineWidth(context, 2);
    
    [[UIColor whiteColor]set];
    CGContextStrokePath(context);
    
}

@end
