//
//  FMData.m
//  FMDB学生管理系统
//
//  Created by kaidan on 15/7/24.
//  Copyright (c) 2015年 kaidan. All rights reserved.
//

#import "FMData.h"

@implementation FMData

+(BOOL)isDB{
    
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* dbPath = [NSString stringWithFormat:@"%@/music.sqlite",path];
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    return [manager fileExistsAtPath:dbPath];
}

+(FMDatabase*)getFMDataBase{
    
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* dbPath = [NSString stringWithFormat:@"%@/music.sqlite",path];
    
    FMDatabase* db = [[FMDatabase alloc]initWithPath:dbPath];

    [db open];
    return db;
    
}

+(BOOL)createTable{
    
    
    FMDatabase* db = [FMData getFMDataBase];
    
    NSString* sql = @" create table music(id integer primary key autoincrement ,songname text not null,singername varchar(50),albumpic_small text,downUrl text,albumname varchar(50),local_url text not null,songid varchar(10) not null)";
    
    if([db executeUpdate:sql]){
        NSLog(@"建表成功");
        [db close];
        return YES;
    }else{
        NSLog(@"建表失败");
    }
    
    [db close];
    return NO;
}

+(BOOL)insertData:(id)data{
    
    itemMusic* item = (itemMusic*)data;
    
    FMDatabase* db = [FMData getFMDataBase];
    
    NSString* sql = @" insert into music(songname,singername,albumpic_small,downUrl,albumname,local_url,songid) values(?,?,?,?,?,?,?)";
    
    if ([db executeUpdate:sql,item.songname,item.singername,item.albumpic_small,item.downUrl,item.albumname,item.local_url,item.songid]) {
        NSLog(@"添加成功");
        [db close];
        return YES;
    }else{
        NSLog(@"添加失败");
        [db close];
        return NO;
    }
}

+(NSArray*)selectData{
    
    NSMutableArray* arr = [NSMutableArray array];
    
    FMDatabase* db = [FMData getFMDataBase];
    
    NSString* sql = @" select * from music ";
    
    FMResultSet* result = [db executeQuery:sql];
    
    while (result.next) {
        
        NSString* songname = [result stringForColumn:@"songname"];
        NSString* singername = [result stringForColumn:@"singername"];
        NSString* albumpic_small = [result stringForColumn:@"albumpic_small"];
        NSString* downUrl = [result stringForColumn:@"downUrl"];
        NSString* albumname = [result stringForColumn:@"albumname"];
        NSString* local_url = [result stringForColumn:@"local_url"];
        NSString* songid = [result stringForColumn:@"songid"];
        
        itemMusic* item = [[itemMusic alloc]init];
        item.songname = songname;
        item.singername = singername;
        item.albumpic_small = albumpic_small;
        item.albumname = albumname;
        item.downUrl = downUrl;
        item.local_url = local_url;
        item.songid = songid;
        [arr addObject:item];
        
        NSLog(@"-数据库保存的条数--%ld",arr.count);
    }
    
    return arr;
}

@end
