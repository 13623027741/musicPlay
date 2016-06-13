
//
//  NetworkingSongController.m
//  MusicPlay
//
//  Created by kaidan on 16/6/3.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import "NetworkingSongController.h"
#import "ReactiveCocoa.h"
#import "Masonry.h"
#import "MusicModel.h"
#import "MBProgressHUD.h"
#import "JinnPopMenu.h"
#import "FBOperate.h"

#define COLOR_BACKGROUND [UIColor colorWithWhite:0.1 alpha:1.000]

@interface NetworkingSongController ()<JinnPopMenuDelegate>

@property(nonatomic,strong)UIAlertController* alert;

@property(nonatomic,strong)UIButton* music_class;

@property(nonatomic,strong)UITextField* textField;

@property(nonatomic,strong)UIButton* cacheMusicList;

@property(nonatomic,strong)UIButton* but;

@property(nonatomic,strong)NSArray* menu;

@property(nonatomic,strong)NSDictionary* dic;

@property(nonatomic,strong)MBProgressHUD* progress;

//@property(nonatomic,strong)JinnPopMenu* popMenu;
//
//@property(nonatomic,strong)NSMutableArray* items;

@end

@implementation NetworkingSongController

+(instancetype)getNetworkingViewController{
    static NetworkingSongController* VC;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        VC = [[NetworkingSongController alloc]init];
    });
    return VC;
}

-(NSArray *)menu{
    if (!_menu) {
        /*
         3=欧美
         5=内地
         6=港台
         16=韩国
         17=日本
         18=民谣
         19=摇滚
         23=销量
         26=热歌
         */
        _menu = @[@"欧美",@"内地",@"港台",@"韩国",@"日本",@"民谣",@"摇滚",@"销量",@"热歌"];
    }
    return _menu;
}

-(NSDictionary *)dic{
    if (!_dic) {
        _dic = @{@"欧美":@3,
                 @"内地":@5,
                 @"港台":@6,
                 @"韩国":@16,
                 @"日本":@17,
                 @"民谣":@18,
                 @"摇滚":@19,
                 @"销量":@23,
                 @"热歌":@26
                 };
    }
    return _dic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addView];
    
    [self setViewWithAutolayout];
    
    [self setSubView];
    
    
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:@"getMusicModel" object:nil]
    subscribeNext:^(NSNotification* noti) {
        [self.progress hide:YES];
        if([noti.object isKindOfClass:[NSArray class]]){
            NSLog(@"通知---通过歌单获取歌曲");
            [self dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"loadData" object:noti.object];
        }else{
            NSLog(@"通过歌单获取歌曲失败");
        }
    }];
    
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:@"getMusicWithMusicName" object:nil]
    subscribeNext:^(NSNotification* noti) {
        [self.progress hide:YES];
        if([noti.object isKindOfClass:[NSArray class]]){
            NSLog(@"通过歌曲名获取歌曲");
            [self dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"loadData" object:noti.object];
            for (itemMusic* item in noti.object) {
                NSLog(@"-[%@]-[%@]--[%@]--[%@]-",item.songname,item.albumpic_small,item.singername,item.albumname);
            }
        }else{
            NSLog(@"通过歌曲名获取歌曲失败");
        }
    }];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.textField.text = nil;
}

-(void)addView{
    
    UIImageView* imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"img"];
    [self.view addSubview:imageView];
    
    
    self.music_class = [[UIButton alloc]init];
    self.textField = [[UITextField alloc]init];
    self.cacheMusicList = [[UIButton alloc]init];
    self.but = [[UIButton alloc]init];
    self.progress = [[MBProgressHUD alloc]init];
    
    [self.view addSubview:self.music_class];
    [self.view addSubview:self.textField];
    [self.view addSubview:self.cacheMusicList];
    [self.view addSubview:self.but];
}

-(void)setViewWithAutolayout{
    
    [self.music_class mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(20);
        make.right.mas_equalTo(self.view.mas_right).offset(-20);
        make.height.mas_equalTo(@50);
        make.top.mas_equalTo(self.view.mas_top).offset(80);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.music_class.mas_left);
        make.right.mas_equalTo(self.music_class.mas_right);
        make.top.mas_equalTo(self.music_class.mas_bottom).offset(10);
        make.height.mas_equalTo(self.music_class.mas_height);
    }];
    
    [self.cacheMusicList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.music_class.mas_left);
        make.right.mas_equalTo(self.music_class.mas_right);
        make.top.mas_equalTo(self.textField.mas_bottom).offset(50);
        make.height.mas_equalTo(self.music_class.mas_height);
    }];
    
    [self.but mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.music_class.mas_left);
        make.right.mas_equalTo(self.music_class.mas_right);
        make.top.mas_equalTo(self.textField.mas_bottom).offset(150);
        make.height.mas_equalTo(self.music_class.mas_height);
    }];
    
}

-(void)setSubView{
    
    [self.music_class setTitle:@"请选择音乐分类" forState:UIControlStateNormal];
    self.music_class.alpha = 0.6;
    [self.music_class setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    self.music_class.layer.cornerRadius = 5;
    self.music_class.backgroundColor = [UIColor whiteColor];
    [[self.music_class rac_signalForControlEvents:UIControlEventTouchUpInside]
    subscribeNext:^(UIButton* sender) {
        [self labelButtonClicked];
    }];
    
    self.textField.alpha = 0.6;
    self.textField.layer.cornerRadius = 5;
    self.textField.placeholder = @"请输入歌曲名";
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.textColor = [UIColor orangeColor];
    
    self.cacheMusicList.alpha = 0.6;
    self.cacheMusicList.backgroundColor = [UIColor whiteColor];
    self.cacheMusicList.layer.cornerRadius = 5;
    [self.cacheMusicList setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.cacheMusicList setTitle:@"加载缓存歌曲" forState:UIControlStateNormal];
    [[self.cacheMusicList rac_signalForControlEvents:UIControlEventTouchUpInside]
    subscribeNext:^(id x) {
        NSLog(@"点击加载缓存");
        NSMutableArray* list = [NSMutableArray array];
        for (itemMusic* item in [FBOperate arrayWithDataBase]) {
            [list addObject:item];
            NSLog(@"--item :%@--",item.songname);
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"getMusicModel" object:list];
    }];
    
    self.but.alpha = 0.6;
    self.but.backgroundColor = [UIColor whiteColor];
    self.but.layer.cornerRadius = 5;
    [self.but setTitle:@"加载歌曲" forState:UIControlStateNormal];
    [self.but setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.but setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [[self.but rac_signalForControlEvents:UIControlEventTouchUpInside]
    subscribeNext:^(id x) {
        [self.progress show:YES];
        if ([self.textField.text isEqualToString:@""]) {
            NSLog(@"----通过歌单加载歌曲[%@]---",self.music_class.titleLabel.text);
            NSNumber* topid = [self.dic objectForKey:self.music_class.titleLabel.text];
            [MusicModel getMusicModel:[topid integerValue]];
            
        }else{
            NSLog(@"有写歌曲。。搜索歌曲...歌曲名[%@]",self.textField.text);
            [MusicModel getMusicWithMusicName:self.textField.text];
        }
    }];
    
}

- (void)labelButtonClicked
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.menu.count; i++)
    {
        JinnPopMenuItem *popMenuItem = [[JinnPopMenuItem alloc] initWithTitle:self.menu[i] titleColor:COLOR_BACKGROUND];
        [popMenuItem.itemLabel.layer setCornerRadius:40];
        [popMenuItem.itemLabel setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
        [items addObject:popMenuItem];
    }
    
    JinnPopMenu *popMenu = [[JinnPopMenu alloc] initWithPopMenus:[items copy]];
    [popMenu setShouldHideWhenBackgroundTapped:YES];
    [popMenu.backgroundView setBackgroundColor:COLOR_BACKGROUND];
    [popMenu setItemSize:CGSizeMake(80, 80)];
    [popMenu setDelegate:self];
    [self.view addSubview:popMenu];
    [popMenu showAnimated:YES];
    [popMenu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.view);
    }];
    
}


#pragma mark -  JinnPopMenuDelegate 代理
- (void)itemSelectedAtIndex:(NSInteger)index popMenu:(JinnPopMenu *)popMenu
{
    NSLog(@"%@",self.menu[index]);
    [self.music_class setTitle:self.menu[index] forState:UIControlStateNormal];
    if (popMenu.tag != 10000)
    {
        [popMenu dismissAnimated:NO];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
