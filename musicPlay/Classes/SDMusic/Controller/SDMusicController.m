//
//  SDMusicController.m
//  MusicPlay
//
//  Created by kaidan on 16/5/24.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import "SDMusicController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SDMusicCell.h"
#import "Masonry.h"
#import "ReactiveCocoa.h"
#import "MusicItem.h"
#import "xTTBLE.h"

#define SCREEN_SIZE [UIScreen mainScreen].bounds.size

@interface SDMusicController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView* tableView;

@property(nonatomic,assign)NSInteger selectorRow;

@end

@implementation SDMusicController

-(instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        
        [self addVisualView];
        
        self.tableView = [[UITableView alloc]init];
        self.tableView.frame = CGRectMake(0, 20, SCREEN_SIZE.width, SCREEN_SIZE.height - 20 - 60);
        [self.tableView registerNib:[UINib nibWithNibName:@"SDMusicCell" bundle:nil] forCellReuseIdentifier:@"cell"];
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.tableView];
        
        self.musicList = [NSMutableArray array];
        
        [self addCancelView];
        
    }
    return self;
}

/**
 *  添加取消按钮
 */
-(void)addCancelView{
    UIVisualEffectView* cancelView = [[UIVisualEffectView alloc]init];
    cancelView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    [self addSubview:cancelView];
    
    [cancelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom);
        make.left.mas_equalTo(self.mas_left);
        make.right.mas_equalTo(self.mas_right);
        make.height.mas_equalTo(@60);
    }];
    
    UIButton* but = [UIButton buttonWithType:UIButtonTypeCustom];
    [but setTitle:@"X" forState:UIControlStateNormal];
    [but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelView addSubview:but];
    
    [[but rac_signalForControlEvents:UIControlEventTouchUpInside]
    subscribeNext:^(UIButton* sender) {
        if (self.onClick) {
            self.onClick();
        }
    }];
    
    [but mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(cancelView.mas_centerX);
        make.centerY.mas_equalTo(cancelView.mas_centerY);
        make.width.mas_equalTo(@100);
        make.height.mas_equalTo(@50);
    }];
    
    
}

/**
 *  添加毛玻璃效果
 */
-(void)addVisualView{
    UIVisualEffectView* visualView = [[UIVisualEffectView alloc]initWithFrame:self.bounds];
    visualView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    [self addSubview:visualView];
    
}


#pragma mark - tableView代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.musicList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SDMusicCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.backgroundColor = [UIColor clearColor];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"SDMusicCell" owner:nil options:nil]lastObject];
    }
    
    MusicItem* item = self.musicList[indexPath.row];
    
    cell.musicName.text = item.musicName;
    
    
    if (self.selectorRow == indexPath.row) {
        
        //更新播放图标
        self.isPlay ? [cell.play setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal] :
        [cell.play setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
        cell.play.userInteractionEnabled = YES;
        cell.play.tag = indexPath.row + 100;
        
        [cell.play addTarget:self action:@selector(changePlay:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIView* redView = [[UIView alloc]init];
        redView.backgroundColor = [UIColor clearColor];
        [cell setBackgroundView:redView];
        [cell setSelectedBackgroundView:redView];
        
    }else{
//        cell.play = nil;
        [cell.play setImage:[[UIImage alloc]init] forState:UIControlStateNormal];
        [cell.play setTitle:@"" forState:UIControlStateNormal];
        cell.play.userInteractionEnabled = NO;
    }
    
    
    
    [[cell.play rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
         NSLog(@"--谁点击了按钮--[%ld]-",indexPath.row);
         NSString* temp = self.isPlay ? @"00" : @"01";
         [[xTTBLE getBLEObj]sendBLEuserData:temp type:BTR_SET_PLAY_STATUS];
         
         [[[NSNotificationCenter defaultCenter]rac_addObserverForName:@"isPlay" object:nil]
          subscribeNext:^(id x) {
              [self.tableView reloadData];
          }];
         
     }];
    
    
    cell.detailTextLabel.text = nil;
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MusicItem* item = self.musicList[indexPath.row];
    NSLog(@"选中哪首曲目--%@-",item.musicName);
    [[xTTBLE getBLEObj]sendBLEuserData:item.musicID type:BTR_SET_PLAY_MUSICID];
    if (!self.isPlay) {
        sleep(1);
        [[xTTBLE getBLEObj]sendBLEuserData:@"01" type:BTR_SET_PLAY_STATUS];
    }
    
    self.selectorRow = indexPath.row;
    [self.tableView reloadData];
}

-(void)changePlay:(UIButton*)sender{
    NSLog(@"---%ld----",sender.tag);
}

-(void)setMusicList:(NSMutableArray *)musicList{
    _musicList = musicList;
    
    [self.tableView reloadData];
}

-(void)setIsPlay:(BOOL)isPlay{
    _isPlay = isPlay;
    
    [self.tableView reloadData];
}

@end
