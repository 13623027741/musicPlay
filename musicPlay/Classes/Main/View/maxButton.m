//
//  maxButton.m
//  MusicPlay
//
//  Created by kaidan on 16/5/24.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import "maxButton.h"
#import "Masonry.h"
@interface maxButton ()

@property(nonatomic,strong)UILabel* lab;

@end
@implementation maxButton


-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self == [super initWithFrame:frame]) {
        
        NSLog(@"--%@-",NSStringFromCGRect(self.frame));
        NSLog(@"--%@-",NSStringFromCGRect(self.bounds));
        
        self.lab = [[UILabel alloc]init];
        self.lab.frame = self.bounds;
        self.lab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.lab];
        
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat x = rect.size.width / 2;
    CGFloat y = rect.size.height / 2;
    CGContextAddArc(context, x, y, x - 5, 0, M_PI * 2, 1);
    CGContextSetLineWidth(context, 3);
    [[UIColor whiteColor]set];
    CGContextStrokePath(context);
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    self.lab.text = title;
}

-(void)setTitleFont:(NSInteger)titleFont{
    _titleFont = titleFont;
    
    UIFont * font= [UIFont fontWithName:@"CXingKaiHKS-Bold" size:titleFont];
    
    self.lab.font = font;
}

-(void)setTitleColor:(UIColor *)titleColor{
    _titleColor = titleColor;
    
    self.lab.textColor = titleColor;
}
@end
