//
//  LocalMusicController.h
//  MusicPlay
//
//  Created by kaidan on 16/5/24.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "music.h"
#import <AVFoundation/AVFoundation.h>
@interface LocalMusicController : UIViewController

@property(nonatomic,strong)AVAudioPlayer* musicPlayer;

+(instancetype)createLocalMusic;

@property(nonatomic,strong)music* musicPlay;

@end
