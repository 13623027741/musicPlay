//
//  LocalMusicController.m
//  MusicPlay
//
//  Created by kaidan on 16/5/24.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import "LocalMusicController.h"
#import "Masonry.h"
#import "ReactiveCocoa.h"
#import "LocalMusicCell.h"
#import "NetworkingSongController.h"
#import "MusicModel.h"
#import "UIImageView+WebCache.h"
#import "HttpTool.h"
#import "xTTBLEdata.h"
#import "FMData.h"
#import "FBOperate.h"

@interface LocalMusicController ()<UICollectionViewDelegate,UICollectionViewDataSource>
/**
 *  音乐列表
 */
@property(nonatomic,strong)UICollectionView* collectionView;
/**
 *  保存音乐model
 */
@property(nonatomic,strong)NSMutableArray* musics;
/**
 *  定时器 用来控制标尺移动
 */
@property(nonatomic,strong)NSTimer* timer;
/**
 *  标尺拖动的最终位置  确定音乐从哪里播放
 */
@property(nonatomic,assign)double musicTime;
/**
 *  下载操作缓存池
 */
@property(nonatomic,strong)NSMutableDictionary* downLoadCache;

@property(nonatomic,strong)NSMutableDictionary* dic;

@property(nonatomic,strong)NSMutableArray* allKey;

@end

static NSString* cellID = @"CollectionView";
int tag = 0;
@implementation LocalMusicController

-(NSMutableArray *)allKey{
    if (!_allKey) {
        _allKey = [NSMutableArray array];
    }
    return _allKey;
}

-(NSMutableDictionary *)dic{
    if (!_dic) {
        _dic = [NSMutableDictionary dictionary];
    }
    return _dic;
}

-(NSMutableDictionary *)downLoadCache{
    if (!_downLoadCache) {
        _downLoadCache = [NSMutableDictionary dictionary];
    }
    return _downLoadCache;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

+(instancetype)createLocalMusic{
    static LocalMusicController* localMusic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        localMusic = [[LocalMusicController alloc]init];
    });
    return localMusic;
}

-(instancetype)init{
    if (self == [super init]) {
        
        UIImageView* bgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img"]];
        bgView.frame = self.view.bounds;
        
        [self.view addSubview:bgView];

        self.musicPlay = [[music alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 320)];
        [self.view addSubview:self.musicPlay];
        
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(self.view.bounds.size.width, 80);
        layout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
        _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView registerNib:[UINib nibWithNibName:@"LocalMusicCell" bundle:nil] forCellWithReuseIdentifier:cellID];
        _collectionView.delegate = self;
        _collectionView.dataSource =self;
        _collectionView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_collectionView];
        
        [[self.musicPlay.but rac_signalForControlEvents:UIControlEventTouchUpInside]
         subscribeNext:^(UIButton* sender) {
             NSLog(@"点击了按钮");
             if (self.musicPlayer.isPlaying) {
                 [self.musicPlayer pause];
                 [sender setImage:[UIImage imageNamed:@"play1"] forState:UIControlStateNormal];
             }else{
                 [self.musicPlayer play];
                 [sender setImage:[UIImage imageNamed:@"stop1"] forState:UIControlStateNormal];
             }
             if (!self.timer) {
                 [self addTimer];
             }else if (self.timer){
                 [self.timer invalidate];
                 self.timer = nil;
                 
             }
         }];
        
        @weakify(self);
        self.musicPlay.changeMusciTime = ^(TXHRulerScrollView* ruler){
            @strongify(self);
            int num = (int)(ruler.rulerValue / ruler.rulerCount * 100);
            
            self.musicPlay.huView.num = num;
            
            self.musicTime = ruler.rulerValue;
            
        };
        self.musicPlay.beginScroll = ^(BOOL isBegin){
            @strongify(self);
            NSLog(@"--222-开始滚动--%d--",isBegin);
            if (isBegin) {
                [self.musicPlayer pause];
                [self.timer setFireDate:[NSDate distantFuture]];
            }else{
                NSLog(@"-1111-%f---",self.musicTime);
                self.musicPlayer.currentTime = self.musicTime;
                
                [self.musicPlayer play];
                [self.timer setFireDate:[NSDate distantPast]];
            }
        };
        
        
        [[self.musicPlay.back rac_signalForControlEvents:UIControlEventTouchUpInside]
        subscribeNext:^(id x) {
            NSLog(@"点击了返回");
            [self dismissViewControllerAnimated:YES completion:nil];
//            [self changeViewController];
        }];
        
        
        [[self.musicPlay.selectorNetworkSong rac_signalForControlEvents:UIControlEventTouchUpInside]
        subscribeNext:^(id x) {
            NSLog(@"进入网络选歌。。");
            [self presentViewController:[NetworkingSongController getNetworkingViewController] animated:YES completion:nil];
        }];
        
        
        [self setViewWithAutoLayout];
        
        
        NSString* musicName = [[NSUserDefaults standardUserDefaults]objectForKey:@"musicName"];
        for (itemMusic* item in self.musics) {
            if ([musicName isEqualToString:item.songname]) {
                self.musicPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:item.music_url error:nil];
            }
        }
        
    }
    return self;
}

//-(void)changeViewController{
//    CATransition *myTransition=[CATransition animation];//创建CATransition
//    myTransition.duration=0.5;//持续时长0.3秒
//    myTransition.timingFunction=UIViewAnimationCurveEaseInOut;//计时函数，从头到尾的流畅度
//    myTransition.type=@"cube";//动画类型
//    //    myTransition.subtype=kCATransitionFromTop;//子类型
//    //要令一个转场生效，组要将动画添加到将要变为动画视图所附着的图层。例如在两个视图控制器之间进行转场，那就将动画添加到窗口的图层中：
//    [[self.view.superview layer]addAnimation:myTransition forKey:nil ];
//    //如果是将控制器内的子视图转场到另一个子视图，就将动画加入到视图控制器的图层。还有一种选择，用视图控制器内部的视图作为替代，将你的子视图作为主视图的子图层：
//    [ self.view.layer addAnimation:myTransition forKey:nil ];
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    NSLog(@"%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]);
    
    _musics = [NSMutableArray array];
    for (itemMusic* item in [FBOperate arrayWithDataBase]) {
        [self.musics addObject:item];
    }
    
    //通知  根据返回的数据刷新列表
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:@"loadData" object:nil]
    subscribeNext:^(NSNotification* noti) {
        [self.musics removeAllObjects];
        NSLog(@"刷新列表");
        NSArray* arr = noti.object;
        for (itemMusic* item in arr) {
            [self.musics addObject:item];
        }
        [self.collectionView reloadData];
    }];
    
    
    [[self.musicPlayer rac_signalForSelector:@selector(audioPlayerEndInterruption:withFlags:) fromProtocol:@protocol(AVAudioPlayerDelegate)]
    subscribeNext:^(id x) {
        NSLog(@"-x-播放完成-%@",x);
    }];
    
    //通知  更新歌词
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:@"musicLyrics" object:nil]
    subscribeNext:^(NSNotification* noti) {
        NSMutableDictionary* dic = noti.object;
        [self.allKey removeAllObjects];
        for (NSNumber* num in dic.allKeys) {
            [self.dic setObject:dic[num] forKey:num];
            [self.allKey addObject:num];
        }
        
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    if (!self.timer) {
//        [self addTimer];
//    }else if (self.timer){
//        [self.timer invalidate];
//        self.timer = nil;
//        [self addTimer];
//    }
}

-(void)addTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(changeMusic) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}

-(void)changeMusic{
    tag ++;
    double timeCount = self.musicPlayer.duration;
    double currentTime = self.musicPlayer.currentTime;
    if (timeCount && currentTime) {
        double count = (currentTime / timeCount) * 100;
//        NSLog(@"--总时间%g---当前时间%g--",timeCount,currentTime);
        NSInteger rulerCount = (NSInteger)timeCount;
        [self.musicPlay.ruler showRulerScrollViewWithCount:rulerCount average:@(1) currentValue:currentTime smallMode:YES isLoad:NO];
        self.musicPlay.huView.num = count;
    }
    
    NSInteger lyricsTime = currentTime;
    if (tag %10 == 0) {
        if (tag == 10000) tag = 0;
        
        for (NSNumber* num in self.allKey) {
            if (lyricsTime == [num integerValue]) {
                self.musicPlay.lyricsLable.text = [self.dic objectForKey:num];
                NSLog(@"-%@---%@",[self.dic objectForKey:num],num);
            }
        }
    }
    
}

-(void)setViewWithAutoLayout{
    
    [self.musicPlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.height.mas_equalTo(@320);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.musicPlay.mas_bottom);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
}

#pragma mark - UICollectionView代理

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.musics.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LocalMusicCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    if (!cell) {
        cell = [[LocalMusicCell alloc]init];
        
    }
    
    itemMusic* item = self.musics[indexPath.row];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:item.albumpic_small]];
    cell.title.text = item.songname;
    cell.albumname.text = item.albumname;
    cell.singername.text = item.singername;
    
    UIView* whiteView = [[UIView alloc]init];
    whiteView.backgroundColor = [UIColor whiteColor];
    whiteView.alpha = 0.3;
    whiteView.layer.cornerRadius = 10;
    cell.backgroundView = whiteView;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if(self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
    
    if (self.musicPlayer) {
        self.musicPlayer = nil;
    }
    
    itemMusic* item = self.musics[indexPath.row];
    
    NSLog(@"%@",item.songname);
    
    [MusicModel getMusicLyricsWithItem:item];
    
    if (item.local_url) {
        
        NSURL* localURL = [[NSURL alloc]initFileURLWithPath:item.local_url];
        self.musicPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:localURL error:nil];
        [self.musicPlayer play];
        if ([self.downLoadCache objectForKey:item.downUrl]) {
            [self.downLoadCache removeObjectForKey:item.downUrl];
        }
        NSLog(@"path %@",localURL.path);
    }else{
        
        if (![self.downLoadCache objectForKey:item.downUrl]) {
            [self.downLoadCache setObject:item forKey:item.downUrl];
            [FBOperate downloadTaskWithItem:item];
        }
        
        @weakify(self);
        [[[NSNotificationCenter defaultCenter]rac_addObserverForName:@"downLoad" object:nil]
        subscribeNext:^(NSNotification* noti) {
            @strongify(self);
            NSLog(@"下载任务完成，通知");
            if ([noti.object isKindOfClass:[itemMusic class]]) {
                itemMusic* temp = (itemMusic*)noti.object;
                
                NSURL* localURL = [[NSURL alloc]initFileURLWithPath:temp.local_url];
                self.musicPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:localURL error:nil];
                [self.musicPlayer play];
                
                if ([self.downLoadCache objectForKey:temp.downUrl]) {
                    [self.downLoadCache removeObjectForKey:temp.downUrl];
                }
                double timeCount = self.musicPlayer.duration;
                double currentTime = self.musicPlayer.currentTime;
                [self.musicPlay.ruler showRulerScrollViewWithCount:timeCount average:@(1) currentValue:currentTime smallMode:YES isLoad:YES];
                
                
            }else if ([noti.object isKindOfClass:[NSNumber class]]){
                NSLog(@"下载音乐失败");
            }
        }];
    }
    
    self.musicPlay.title.text = item.songname;
    int count = (int)self.musicPlayer.duration;
    
    [self.musicPlay.ruler showRulerScrollViewWithCount:count average:@(1) currentValue:0 smallMode:YES isLoad:YES];
    if (!self.timer) {
        [self addTimer];
    }
    
    [[NSUserDefaults standardUserDefaults]setObject:item.songname forKey:@"musicName"];
}


@end
