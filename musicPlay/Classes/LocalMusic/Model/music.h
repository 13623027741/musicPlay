//
//  music.h
//  MusicPlay
//
//  Created by kaidan on 16/5/31.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HuView.h"
#import "TXHRrettyRuler.h"

@interface music : UIView


/**
 *  状态圈
 */
@property(nonatomic,strong)HuView* huView;
/**
 *  暂停 播放 按钮
 */
@property(nonatomic,strong)UIButton* but;
/**
 *  标尺控件
 */
@property(nonatomic,strong)TXHRrettyRuler* ruler;
/**
 *  开始拖动后的位置
 */
@property(nonatomic,copy)void(^changeMusciTime)(TXHRulerScrollView* ruler);
/**
 *  标题
 */
@property(nonatomic,strong)UILabel* title;
/**
 *  是否开始滚动
 */
@property(nonatomic,copy)void(^beginScroll)(BOOL isBegin);
/**
 *  返回
 */
@property(nonatomic,strong)UIButton* back;
/**
 *  进入网络选歌
 */
@property(nonatomic,strong)UIButton* selectorNetworkSong;
/**
 *  歌词
 */
@property(nonatomic,strong)UILabel* lyricsLable;

@end
