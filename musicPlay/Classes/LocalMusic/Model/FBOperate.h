//
//  FBOperate.h
//  MusicPlay
//
//  Created by kaidan on 16/6/8.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicModel.h"
@interface FBOperate : NSObject
/**
 *  通过item模型下载歌曲
 */
+(void)downloadTaskWithItem:(itemMusic*)item;
/**
 *  通过数据库取出音乐model
 */
+(NSArray*)arrayWithDataBase;

@end
