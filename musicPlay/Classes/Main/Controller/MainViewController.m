
//
//  MainViewController.m
//  MusicPlay
//
//  Created by kaidan on 16/5/24.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import "MainViewController.h"
#import "maxButton.h"
#import "Masonry.h"
#import "ReactiveCocoa.h"
#import "LineCircleView.h"
#import "RACEXTScope.h"
#import "SDMusicController.h"
#import "xTTBLE.h"
#import "MusicItem.h"
#import "LocalMusicController.h"

#define SCREEN_SIZE [UIScreen mainScreen].bounds.size

@interface MainViewController ()

@property (nonatomic,strong) maxButton   * button;

@property (nonatomic,strong) UIButton    * selectorSDMusic;

@property (nonatomic,strong) UIImageView * backgroundIamgeView;

@property (nonatomic,strong) UIView      * alphaView;
/**
 *  SD音乐列表
 */
@property(nonatomic,strong)SDMusicController* sdMusicView;

@property(nonatomic,strong)NSTimer* timer;

@end

@implementation MainViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self addSubView];
    
    @weakify(self);
    
    
    //解析歌曲
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:@"MusicItem" object:nil]
    subscribeNext:^(NSNotification* noti) {
        @strongify(self);
        MusicItem* item = noti.object;
        for (MusicItem* musicItem in self.sdMusicView.musicList) {
            if([musicItem.musicName isEqualToString:item.musicName]){
                [self.sdMusicView.musicList addObject:item];
            }
        }
    }];
    
    //判断是否正在播放
    [[[[NSNotificationCenter defaultCenter]rac_addObserverForName:@"isPlay" object:nil]
    map:^id(NSNotification* noti) {
        if ([noti.object isEqualToString:@"00"]) {
            return @(NO);
        }
        return @(YES);
    }]
    subscribeNext:^(NSNumber* value) {
        @strongify(self);
        self.sdMusicView.isPlay = [value boolValue];
    }];
    
    [[self.button rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(UIButton* sender) {
         NSLog(@"------本地播放-------");
         @strongify(self);
         [self addAnimation];  
         [self presentViewController:[LocalMusicController createLocalMusic] animated:YES completion:nil];
         
         
         
         
     }];
    
    [[self.selectorSDMusic rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
//         @strongify(self);
         NSLog(@"-SD卡播放--");
         [[xTTBLE getBLEObj]sendBLEuserData:@"00" type:BTR_SWITCH_MODE];
//         [self addTransition:YES];
         sleep(2);
         [[xTTBLE getBLEObj]sendBLEuserData:@"" type:BTR_GET_A2DP_CONNECT_STATE];

         
     }];
    self.sdMusicView.onClick = ^(){
        NSLog(@"-点击了返回--");
        @strongify(self);
        [self addTransition:NO];
    };
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([LocalMusicController createLocalMusic] &&
        [LocalMusicController createLocalMusic].musicPlayer.playing) {
        NSLog(@"开启动画");
        [self addTimerAnimation];
    }else{
        NSLog(@"关闭动画");
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}

-(void)addTransition:(BOOL)isNext{
    
    if (isNext) {
        CATransition* transition = [CATransition animation];
        transition.type = @"pageCurl";
        transition.duration = 1;
        [self.view.layer addAnimation:transition forKey:nil];
        transition.removedOnCompletion = NO;
        transition.fillMode = kCAFillModeForwards;
        
        CAKeyframeAnimation* keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        keyAnimation.values = @[@0,@1];
        keyAnimation.duration = 0.8;
        keyAnimation.removedOnCompletion = NO;
        keyAnimation.fillMode = kCAFillModeForwards;
        
        CAAnimationGroup* group = [CAAnimationGroup animation];
        group.animations = @[transition,keyAnimation];
        group.duration = 1;
        group.removedOnCompletion = NO;
        
        self.sdMusicView.layer.opacity = 1;
        [self.sdMusicView.layer addAnimation:group forKey:nil];
    }else{
        CATransition* transition = [CATransition animation];
        transition.type = @"pageUnCurl";
        transition.duration = 1;
        [self.view.layer addAnimation:transition forKey:nil];
        transition.removedOnCompletion = NO;
        transition.fillMode = kCAFillModeForwards;
        
        CAKeyframeAnimation* keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        keyAnimation.values = @[@1,@0];
        keyAnimation.duration = 1;
        keyAnimation.removedOnCompletion = NO;
        keyAnimation.fillMode = kCAFillModeForwards;
        
        CAAnimationGroup* group = [CAAnimationGroup animation];
        group.animations = @[transition,keyAnimation];
        group.duration = 1;
        group.removedOnCompletion = NO;
        
        self.sdMusicView.layer.opacity = 0;
        [self.sdMusicView.layer addAnimation:group forKey:nil];
    }
}

-(void)addSubView{
    UIImage* image = [UIImage imageNamed:@"img"];
    self.backgroundIamgeView = [[UIImageView alloc]initWithImage:image];
    
//    self.alphaView = [[UIView alloc]init];
//    self.alphaView.backgroundColor = [UIColor greenColor];
//    self.alphaView.alpha = 0.1f;
    
    [self.view addSubview:self.backgroundIamgeView];
//    [self.view addSubview:self.alphaView];
    
    
    CGRect rect = CGRectMake(SCREEN_SIZE.width / 2 - 100, (SCREEN_SIZE.height / 2 - 200), 200, 200);
    self.button = [[maxButton alloc]initWithFrame:rect];
    self.button.alpha = 0.8f;
    self.button.title = @"本地播放";
    self.button.titleFont = 45;
    self.button.titleColor = [UIColor whiteColor];
    [self.view addSubview:self.button];
    
    
    
    self.selectorSDMusic = [[UIButton alloc]init];
    [self.selectorSDMusic setTitle:@"SD 卡播放" forState:UIControlStateNormal];
    [self.selectorSDMusic setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.selectorSDMusic setBackgroundColor:[UIColor orangeColor]];
    self.selectorSDMusic.layer.cornerRadius = 20;
    [self.view addSubview:self.selectorSDMusic];
    
    //设置动画的view
    for (NSInteger i = 0; i < 3; i++) {
        UIImageView* img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg"]];
        img.center = self.button.center;
        img.bounds = CGRectMake(0, 0, 200, 200);
        img.tag = 100 + i;
        [self.view addSubview:img];
    }
    

    
    self.sdMusicView = [[SDMusicController alloc]initWithFrame:self.view.bounds];
    self.sdMusicView.layer.opacity = 0;
    [self.view addSubview:self.sdMusicView];
    
    [self setViewWithAutolayout];

}
/**
 *  添加动画效果
 */
-(void)addAnimation{
    
    for (NSInteger i = 0; i < 3; i++) {
        
        UIImageView* img = (UIImageView*)[self.view viewWithTag:(100 + i)];
        
        CAKeyframeAnimation* keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        CAKeyframeAnimation* alphaAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        
        
        keyAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 0)],
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 0)]
                                ];
        alphaAnimation.values = @[@1,@0];
        
        CAAnimationGroup* group = [CAAnimationGroup animation];
        group.animations = @[keyAnimation,alphaAnimation];
        group.duration = (i + 1) * 0.8;
        [img.layer addAnimation:group forKey:nil];
    }
    
    
}
/**
 *  开启循环播放动画
 */
-(void)addTimerAnimation{
    
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2.4 target:self selector:@selector(addAnimation) userInfo:nil repeats:YES];
    }
}

-(void)setViewWithAutolayout{
    [self.backgroundIamgeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    [self.alphaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    [self.selectorSDMusic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerX).offset(200);
        make.width.mas_equalTo(@150);
        make.height.mas_equalTo(@40);
    }];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
