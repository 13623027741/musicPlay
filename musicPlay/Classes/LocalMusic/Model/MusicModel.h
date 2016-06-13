//
//  MusicModel.h
//  MusicPlay
//
//  Created by kaidan on 16/6/6.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MusicModel : NSObject
/**
 *  通过歌单查找音乐
 */
+(void)getMusicModel:(NSInteger)topid;
/**
 *  通过音乐名查找音乐
 */
+(void)getMusicWithMusicName:(NSString*)musicName;
/**
 *  通过模型查找歌词
 */
+(void)getMusicLyricsWithItem:(id)item;
@end


@interface itemMusic : NSObject
/**
 *  音乐名
 */
@property(nonatomic,copy)NSString* songname;
/**
 *  在线播放地址
 */
@property(nonatomic,copy)NSString* m4a;
/**
 *  图片地址
 */
@property(nonatomic,copy)NSString* albumpic_small;
/**
 *  下载地址
 */
@property(nonatomic,copy)NSString* downUrl;
/**
 *  歌曲ID
 */
@property(nonatomic,copy)NSString* songid;
/**
 *  歌手
 */
@property(nonatomic,copy)NSString* singername;
/**
 *  专辑
 */
@property(nonatomic,copy)NSString* albumname;
/**
 *  歌单在线播放地址
 */
@property(nonatomic,copy)NSString* url;
/**
 *  本地歌曲图片资源
 */
@property(nonatomic,copy)UIImage* image;
/**
 *  歌曲的url
 */
@property(nonatomic,copy)NSURL* music_url;

/**
 *  本地路径
 */
@property(nonatomic,copy)NSString* local_url;

/**
 *  字典转模型
 */
+(instancetype)getMusicItem:(NSDictionary*)dic;
/**
 *  字符串转16进制
 */
+ (NSString *)hexStringFromString:(NSString *)string;
/**
 *  16进制转字符串
 */
+ (NSString *)stringFromHexString:(NSString *)hexString;

@end
