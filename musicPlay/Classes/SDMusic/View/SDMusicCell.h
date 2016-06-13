//
//  SDMusicCell.h
//  MusicPlay
//
//  Created by kaidan on 16/5/25.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDMusicCell : UITableViewCell
/**
 *  音乐名
 */
@property (weak, nonatomic) IBOutlet UILabel *musicName;
/**
 *  音乐作者
 */
@property (weak, nonatomic) IBOutlet UILabel *authorName;

/**
 *  播放
 */
@property (weak, nonatomic) IBOutlet UIButton *play;

@property(nonatomic,copy)void(^changePlayModel)();

@end
