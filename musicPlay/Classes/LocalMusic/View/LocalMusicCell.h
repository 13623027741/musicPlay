//
//  LocalMusicCell.h
//  MusicPlay
//
//  Created by kaidan on 16/5/31.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalMusicCell : UICollectionViewCell
/**
 *  歌曲图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
/**
 *  歌曲名
 */
@property (weak, nonatomic) IBOutlet UILabel *title;
/**
 *  专辑名
 */
@property (weak, nonatomic) IBOutlet UILabel *albumname;
/**
 *  歌手
 */
@property (weak, nonatomic) IBOutlet UILabel *singername;


@end
