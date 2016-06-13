//
//  SDMusicController.h
//  MusicPlay
//
//  Created by kaidan on 16/5/24.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDMusicController : UIView

@property(nonatomic,copy)void(^onClick)();
/**
 *  音乐列表
 */
@property(nonatomic,strong)NSMutableArray* musicList;
/**
 *  是否正在播放
 */
@property(nonatomic,assign)BOOL isPlay;

@end
