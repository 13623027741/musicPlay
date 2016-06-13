//
//  FBOperate.m
//  MusicPlay
//
//  Created by kaidan on 16/6/8.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import "FBOperate.h"
#import "AFNetworking.h"
#import "FMData.h"
@implementation FBOperate

+(void)downloadTaskWithItem:(itemMusic*)item{
    
    //通过  NSURLSessionDownloadTask  下载歌曲
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager* manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:config];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:item.downUrl]];
    
    NSURLSessionDownloadTask* task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"下载进度---%g-",downloadProgress.fractionCompleted);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL* url = [[NSFileManager defaultManager]URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        
        return [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",item.songname]];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        item.local_url = [NSString stringWithFormat:@"%@/%@.mp3",path,item.songname];
        [FMData insertData:item];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"downLoad" object:item];
        
    }];
    
    [task resume];
}


+(NSArray*)arrayWithDataBase{
    NSMutableArray* arr = [NSMutableArray array];
    
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    
    for (itemMusic* item in [FMData selectData]) {
        NSString* urlPath = [NSString stringWithFormat:@"%@/%@.mp3",path,item.songname];
        item.local_url = urlPath;
        
        [arr addObject:item];
    }
    
    return arr;
}

@end
