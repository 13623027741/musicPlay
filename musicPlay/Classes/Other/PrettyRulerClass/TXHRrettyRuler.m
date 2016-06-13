//
//  TXHRrettyRuler.m
//  PrettyRuler
//
//  Created by GXY on 15/12/11.
//  Copyright © 2015年 Tangxianhai. All rights reserved.
//  withCount:(NSUInteger)count average:(NSUInteger)average

#import "TXHRrettyRuler.h"

#define SHEIGHT 8 // 中间指示器顶部闭合三角形高度
#define INDICATORCOLOR [UIColor redColor].CGColor // 中间指示器颜色

@implementation TXHRrettyRuler {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
        _rulerScrollView = [self rulerScrollView];
        _rulerScrollView.rulerHeight =90;
        _rulerScrollView.rulerWidth = frame.size.width;
        
    }
    return self;
}

- (void)showRulerScrollViewWithCount:(NSUInteger)count
                             average:(NSNumber *)average
                        currentValue:(CGFloat)currentValue
                           smallMode:(BOOL)mode
                              isLoad:(BOOL)isLoad
{
    
    NSAssert(_rulerScrollView != nil, @"***** 调用此方法前，请先调用 initWithFrame:(CGRect)frame 方法初始化对象 rulerScrollView\n");
    NSAssert(currentValue < [average floatValue] * count + 1, @"***** currentValue 不能大于直尺最大值（count * average）\n");
    
//    if (currentValue < [average floatValue] * count) {
//        return;
//    }
    _rulerScrollView.rulerAverage = average;
    _rulerScrollView.rulerCount = count;
    _rulerScrollView.rulerValue = currentValue;
    _rulerScrollView.mode = mode;
    [_rulerScrollView drawRuler:isLoad];
    [self addSubview:_rulerScrollView];
    if(isLoad){
        [self drawRacAndLine];
    }
}

- (TXHRulerScrollView *)rulerScrollView {
    TXHRulerScrollView * rScrollView = [TXHRulerScrollView new];
    rScrollView.delegate = self;
    rScrollView.showsHorizontalScrollIndicator = NO;
    return rScrollView;
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(TXHRulerScrollView *)scrollView {
    CGFloat offSetX = scrollView.contentOffset.x + self.frame.size.width / 2 - DISTANCELEFTANDRIGHT;
    CGFloat ruleValue = (offSetX / DISTANCEVALUE) * [scrollView.rulerAverage floatValue];
    if (ruleValue < 0.f) {
        return;
    } else if (ruleValue > scrollView.rulerCount * [scrollView.rulerAverage floatValue]) {
        return;
    }
    if (self.rulerDeletate) {
        if (!scrollView.mode) {
            scrollView.rulerValue = ruleValue;
        }
        scrollView.mode = NO;
        [self.rulerDeletate txhRrettyRuler:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"开始滚动---lalala");
    if ([self.rulerDeletate respondsToSelector:@selector(BeginDecelerating:)]) {
        [self.rulerDeletate BeginDecelerating:YES];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    NSLog(@"---开始滚动---hehehe-");
}

- (void)scrollViewDidEndDecelerating:(TXHRulerScrollView *)scrollView {
//    NSLog(@"结束滚动----");
    if ([self.rulerDeletate respondsToSelector:@selector(BeginDecelerating:)]) {
        [self.rulerDeletate BeginDecelerating:NO];
    }
    
    [self animationRebound:scrollView];
}



- (void)scrollViewDidEndDragging:(TXHRulerScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.rulerDeletate respondsToSelector:@selector(BeginDecelerating:)]) {
        [self.rulerDeletate BeginDecelerating:NO];
    }
    
    [self animationRebound:scrollView];
}

- (void)animationRebound:(TXHRulerScrollView *)scrollView {
    CGFloat offSetX = scrollView.contentOffset.x + self.frame.size.width / 2 - DISTANCELEFTANDRIGHT;
    CGFloat oX = (offSetX / DISTANCEVALUE) * [scrollView.rulerAverage floatValue];
#ifdef DEBUG
//    NSLog(@"ago*****************ago:oX:%f",oX);
#endif
    if ([self valueIsInteger:scrollView.rulerAverage]) {
        oX = [self notRounding:oX afterPoint:0];
    }
    else {
        oX = [self notRounding:oX afterPoint:1];
    }
#ifdef DEBUG
//    NSLog(@"after*****************after:oX:%.1f",oX);
#endif
    CGFloat offX = (oX / ([scrollView.rulerAverage floatValue])) * DISTANCEVALUE + DISTANCELEFTANDRIGHT - self.frame.size.width / 2;
    [UIView animateWithDuration:.2f animations:^{
        scrollView.contentOffset = CGPointMake(offX, 0);
    }];
}

- (void)drawRacAndLine {

    @autoreleasepool {
        //    // 圆弧
        //    CAShapeLayer *shapeLayerArc = [CAShapeLayer layer];
        //    shapeLayerArc.strokeColor = [UIColor lightGrayColor].CGColor;
        //    shapeLayerArc.fillColor = [UIColor clearColor].CGColor;
        //    shapeLayerArc.lineWidth = 1.f;
        //    shapeLayerArc.lineCap = kCALineCapButt;
        //    shapeLayerArc.frame = self.bounds;
        //
        //    // 渐变
        //    CAGradientLayer *gradient = [CAGradientLayer layer];
        //    gradient.frame = self.bounds;
        //
        //    gradient.colors = @[(id)[[UIColor whiteColor] colorWithAlphaComponent:1.f].CGColor,
        //                        (id)[[UIColor whiteColor] colorWithAlphaComponent:0.0f].CGColor,
        //                        (id)[[UIColor whiteColor] colorWithAlphaComponent:1.f].CGColor];
        //
        //    gradient.locations = @[[NSNumber numberWithFloat:0.0f],
        //                           [NSNumber numberWithFloat:0.6f]];
        //
        //    gradient.startPoint = CGPointMake(0, .5);
        //    gradient.endPoint = CGPointMake(1, .5);
        //
        //    CGMutablePathRef pathArc = CGPathCreateMutable();
        //    CGPathMoveToPoint(pathArc, NULL, 0, DISTANCETOPANDBOTTOM);
        //    CGPathAddQuadCurveToPoint(pathArc, NULL, self.frame.size.width / 2, - 20, self.frame.size.width, DISTANCETOPANDBOTTOM);
        //
        //    shapeLayerArc.path = pathArc;
        ////    [self.layer addSublayer:shapeLayerArc];
        ////    [self.layer addSublayer:gradient];
        
        // 红色指示器
        CAShapeLayer *shapeLayerLine = [CAShapeLayer layer];
        shapeLayerLine.strokeColor = [UIColor redColor].CGColor;
        shapeLayerLine.fillColor = INDICATORCOLOR;
        shapeLayerLine.lineWidth = 1.f;
        shapeLayerLine.lineCap = kCALineCapSquare;
        
        NSUInteger ruleHeight = 20; // 文字高度
        CGMutablePathRef pathLine = CGPathCreateMutable();
        CGPathMoveToPoint(pathLine, NULL, self.frame.size.width / 2, self.frame.size.height - DISTANCETOPANDBOTTOM - ruleHeight);
        CGPathAddLineToPoint(pathLine, NULL, self.frame.size.width / 2, DISTANCETOPANDBOTTOM + SHEIGHT);
        
        CGPathAddLineToPoint(pathLine, NULL, self.frame.size.width / 2 - SHEIGHT / 2, DISTANCETOPANDBOTTOM);
        CGPathAddLineToPoint(pathLine, NULL, self.frame.size.width / 2 + SHEIGHT / 2, DISTANCETOPANDBOTTOM);
        CGPathAddLineToPoint(pathLine, NULL, self.frame.size.width / 2, DISTANCETOPANDBOTTOM + SHEIGHT);
        
        shapeLayerLine.path = pathLine;
        [self.layer addSublayer:shapeLayerLine];
        
        //绘制线条
        CAShapeLayer* topLine = [CAShapeLayer layer];
        topLine.frame = CGRectMake(0, 0, self.bounds.size.width, 1);
        topLine.lineWidth = 1;
        topLine.backgroundColor = [UIColor whiteColor].CGColor;
        
        CAShapeLayer* bottomLine = [CAShapeLayer layer];
        bottomLine.frame = CGRectMake(0,self.bounds.size.height, self.bounds.size.width, 1);
        bottomLine.lineWidth = 1;
        bottomLine.backgroundColor = [UIColor whiteColor].CGColor;
        
        [self.layer addSublayer:topLine];
        [self.layer addSublayer:bottomLine];
    }
    
}

#pragma mark - tool method

- (CGFloat)notRounding:(CGFloat)price afterPoint:(NSInteger)position {
    NSDecimalNumberHandler*roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber*ouncesDecimal;
    NSDecimalNumber*roundedOunces;
    ouncesDecimal = [[NSDecimalNumber alloc]initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [roundedOunces floatValue];
}

- (BOOL)valueIsInteger:(NSNumber *)number {
    NSString *value = [NSString stringWithFormat:@"%f",[number floatValue]];
    if (value != nil) {
        NSString *valueEnd = [[value componentsSeparatedByString:@"."] objectAtIndex:1];
        NSString *temp = nil;
        for(int i =0; i < [valueEnd length]; i++)
        {
            temp = [valueEnd substringWithRange:NSMakeRange(i, 1)];
            if (![temp isEqualToString:@"0"]) {
                return NO;
            }
        }
    }
    return YES;
}


@end
