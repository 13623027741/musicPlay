//
//  MusicItem.h
//  MusicPlay
//
//  Created by kaidan on 16/5/30.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicItem : NSObject

@property(nonatomic,copy)NSString* musicName;

@property(nonatomic,copy)NSString* musicID;

+(instancetype)creactMusicItemWithData:(NSString*)data;

@end
