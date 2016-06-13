//
//  FMData.h
//  FMDB学生管理系统
//
//  Created by kaidan on 15/7/24.
//  Copyright (c) 2015年 kaidan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "MusicModel.h"
@interface FMData : NSObject

/**
 *  创建数据表
 */
+(BOOL)createTable;
/**
 *  插入数据
 */
+(BOOL)insertData:(id)data;
/**
 *  读取数据
 */
+(NSArray*)selectData;
/**
 *  判断是否创建数据库
 */
+(BOOL)isDB;

@end
