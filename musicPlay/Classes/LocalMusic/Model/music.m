//
//  music.m
//  MusicPlay
//
//  Created by kaidan on 16/5/31.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import "music.h"
#import "Masonry.h"
#import "ReactiveCocoa.h"

@interface music ()<TXHRrettyRulerDelegate>


@end

@implementation music

-(instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        
        self.huView = [[HuView alloc]init];
        self.huView.backgroundColor = [UIColor clearColor];
        self.changeMusciTime = ^(TXHRulerScrollView* ruler){
            
        };
        self.beginScroll = ^(BOOL isBegin){
            
        };
        
        [self addSubview:self.huView];
        
        self.but = [[UIButton alloc]init];
        [self.but setImage:[UIImage imageNamed:@"stop1"] forState:UIControlStateNormal];
        self.but.alpha = .8f;
        
        [self.huView addSubview:self.but];
        
        self.ruler = [[TXHRrettyRuler alloc]initWithFrame:CGRectMake(0, 250,self.bounds.size.width,70)];
        self.ruler.rulerDeletate = self;
        [self.ruler showRulerScrollViewWithCount:180 average:@(1) currentValue:0 smallMode:YES isLoad:YES];
        [self addSubview:self.ruler];
        
        
        self.title = [[UILabel alloc]init];
        self.title.font = [UIFont systemFontOfSize:13];
        self.title.text = @"";
        self.title.textColor = [UIColor whiteColor];
        self.title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.title];
        

        self.lyricsLable = [[UILabel alloc]init];
        self.lyricsLable.font = [UIFont systemFontOfSize:13];
        self.lyricsLable.text = @"";
        self.lyricsLable.textColor =[UIColor whiteColor];
        self.lyricsLable.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.lyricsLable];
        
        self.back = [[UIButton alloc]init];
        [self.back setImage:[UIImage imageNamed:@"quxiao"] forState:UIControlStateNormal];
        self.back.alpha = .5f;
        [self addSubview:self.back];
        
        
//        [[self rac_signalForSelector:@selector(BeginDecelerating:)
//                        fromProtocol:@protocol(TXHRrettyRulerDelegate)]
//        subscribeNext:^(NSNumber* value) {
//            @strongify(self);
//            NSLog(@"--444-是否开始滚动----%d----",[value boolValue]);
//            if (self.beginScroll) {
//                self.beginScroll([value boolValue]);
//            }
//        }];
//        
//        [[self rac_signalForSelector:@selector(txhRrettyRuler:)
//                       fromProtocol:@protocol(TXHRrettyRulerDelegate)]
//        subscribeNext:^(TXHRulerScrollView* rulerScrollView) {
//            NSLog(@"-----");
//            if (self.changeMusciTime) {
//                self.changeMusciTime(rulerScrollView);
//            }
//        }];
        
        self.selectorNetworkSong = [[UIButton alloc]init];
        [self.selectorNetworkSong setImage:[UIImage imageNamed:@"list"] forState:UIControlStateNormal];
        self.selectorNetworkSong.alpha = 0.5;
        [self addSubview:self.selectorNetworkSong];
        
        
        [self setViewWithAutoLayout];
        
    }
    return self;
}


-(void)setViewWithAutoLayout{
    
    [self.huView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.right.mas_equalTo(self.mas_right);
        make.top.mas_equalTo(self.mas_top);
        make.height.mas_equalTo(@250);
    }];
    
    [self.lyricsLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.mas_equalTo(self.ruler.mas_top);
        make.height.mas_equalTo(@30);
    }];
    
    [self.but mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.huView.mas_centerX);
        make.width.mas_equalTo(@70);
        make.height.mas_equalTo(@70);
        make.centerY.mas_equalTo(self.huView.mas_bottom).offset(-90);
    }];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left);
        make.right.mas_equalTo(self.mas_right);
        make.top.mas_equalTo(self.mas_top).offset(40);
        make.height.mas_equalTo(@30);
    }];
    
    [self.back mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.huView.mas_left).offset(10);
        make.top.mas_equalTo(self.huView.mas_top).offset(30);
        make.width.mas_equalTo(@20);
        make.height.mas_equalTo(@20);
    }];
    
    [self.selectorNetworkSong mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.huView.mas_right).offset(-10);
        make.top.mas_equalTo(self.huView.mas_top).offset(20);
        make.width.mas_equalTo(@40);
        make.height.mas_equalTo(@40);
    }];
}


#pragma mark - daili

-(void)BeginDecelerating:(BOOL)begin{
//    NSLog(@"--444-是否开始滚动----%d----",begin);
    if (self.beginScroll) {
        self.beginScroll(begin);
    }
}
-(void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView{
//    NSLog(@"-----");
    if (self.changeMusciTime) {
        self.changeMusciTime(rulerScrollView);
    }
}

@end
