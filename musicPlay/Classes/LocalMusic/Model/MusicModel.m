//
//  MusicModel.m
//  MusicPlay
//
//  Created by kaidan on 16/6/6.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import "MusicModel.h"
#import "MJExtension.h"
#import "HttpTool.h"
#import "xTTBLEdata.h"

#define MUSIC_URL @"http://route.showapi.com/213-4"
#define MUSIC_NAME_URL @"http://route.showapi.com/213-1"
#define MUSIC_LYRICS @"http://route.showapi.com/213-2"
#define APP_ID @"20157"
#define APP_SECRET @"8e80d2caa99d493c865eeaa79408fc5f"

@implementation MusicModel

+(void)getMusicModel:(NSInteger)topid{
    
    NSMutableArray* list = [NSMutableArray array];
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[ NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    
    NSString* time = [formatter stringFromDate:date];
    
    
//    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSDictionary* dic = @{@"showapi_appid":APP_ID,@"showapi_sign":APP_SECRET,@"topid":[NSString stringWithFormat:@"%ld",topid],@"showapi_timestamp":time};
    
    [HttpTool POST:MUSIC_URL parameters:dic success:^(id responseObject) {
        NSArray* musicList = responseObject[@"showapi_res_body"][@"pagebean"][@"songlist"];
        for (NSInteger i = 0; i < musicList.count; i++) {
            NSDictionary* d = musicList[i];
            itemMusic* item = [itemMusic getMusicItem:d];
//            item.local_url = [NSString stringWithFormat:@"%@/%@.mp3",path,item.songname];
            [list addObject:item];
        }
        NSLog(@"--数据%ld--",list.count);
        [[NSNotificationCenter defaultCenter]postNotificationName:@"getMusicModel" object:list];
    } failure:^(NSError *error) {
        NSLog(@"歌单获取失败");
        [[NSNotificationCenter defaultCenter]postNotificationName:@"getMusicModel" object:@(NO)];
    }];
    
}

+(void)getMusicWithMusicName:(NSString*)musicName{
    NSMutableArray* arr = [NSMutableArray array];
    
    
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[ NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    
    NSString* time = [formatter stringFromDate:date];
    
//    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSDictionary* dic = @{@"showapi_appid":APP_ID,@"showapi_sign":APP_SECRET,@"keyword":musicName,@"showapi_timestamp":time};
    
    [HttpTool POST:MUSIC_NAME_URL parameters:dic success:^(id responseObject) {
        NSArray* list = responseObject[@"showapi_res_body"][@"pagebean"][@"contentlist"];
        NSString* name = responseObject[@"showapi_res_body"][@"pagebean"][@"w"];
        NSLog(@"%@",responseObject);
        for (NSInteger i = 0; i < list.count; i++) {
            itemMusic* item = [itemMusic getMusicItem:list[i]];
            item.songname = name;
//            item.local_url = [NSString stringWithFormat:@"%@/%@.mp3",path,item.songname];
            [arr addObject:item];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"getMusicWithMusicName" object:arr];
    } failure:^(NSError *error) {
        NSLog(@"歌曲获取失败");
        [[NSNotificationCenter defaultCenter]postNotificationName:@"getMusicWithMusicName" object:@(NO)];
    }];
}

+(void)getMusicLyricsWithItem:(id)item{
    
    itemMusic* musicItem = item;
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[ NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    
    NSString* time = [formatter stringFromDate:date];
    
    NSDictionary* dic = @{@"showapi_appid":APP_ID,@"showapi_sign":APP_SECRET,@"showapi_timestamp":time,@"musicid":musicItem.songid};
    
    [HttpTool POST:MUSIC_LYRICS parameters:dic success:^(id responseObject) {
        NSString* lyrics = responseObject[@"showapi_res_body"][@"lyric"];
        lyrics = [lyrics stringByReplacingOccurrencesOfString:@"&#32;" withString:@" "];
        lyrics = [lyrics stringByReplacingOccurrencesOfString:@"&#58;" withString:@":"];
        lyrics = [lyrics stringByReplacingOccurrencesOfString:@"&#46;" withString:@"."];
        lyrics = [lyrics stringByReplacingOccurrencesOfString:@"[" withString:@""];
        lyrics = [lyrics stringByReplacingOccurrencesOfString:@"]" withString:@""];
        lyrics = [lyrics stringByReplacingOccurrencesOfString:@"&#40;" withString:@"("];
        lyrics = [lyrics stringByReplacingOccurrencesOfString:@"&#41;" withString:@")"];
        lyrics = [lyrics stringByReplacingOccurrencesOfString:@"&#45;" withString:@"-"];

        NSMutableArray* list = [NSMutableArray array];
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        for (NSString* str in [lyrics componentsSeparatedByString:@"&#10;"]) {
            
            if (str.length > 6 && [[str substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"."]) {
                [list addObject:str];
                NSLog(@"%@",str);
            }
        }
        
        for (NSString* str in list) {
            double t = [MusicModel timeWithLyrics:[str substringToIndex:8]];
            [dic setObject:[str substringFromIndex:8] forKey:@(t)];
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"musicLyrics" object:dic];
        
    } failure:^(NSError *error) {
        NSLog(@"歌词获取失败");
    }];
}

+(double)timeWithLyrics:(NSString*)temp{
    
    double minute = [[temp substringWithRange:NSMakeRange(0, 2)] doubleValue];
    double second = [[temp substringWithRange:NSMakeRange(3, 2)] doubleValue];
    double msec = [[temp substringWithRange:NSMakeRange(6, 2)] doubleValue];
    
    if (msec == 0) {
        return [[NSString stringWithFormat:@"%g.%g",minute*60+second,msec] doubleValue];
    }else{
        return [[NSString stringWithFormat:@"%g",minute*60+second] doubleValue];
    }
}

@end


@implementation itemMusic

+(instancetype)getMusicItem:(NSDictionary*)dic{
    itemMusic* item = [itemMusic mj_objectWithKeyValues:dic];
    return item;
}


+ (NSString *)hexStringFromString:(NSString *)string

{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];//16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

+ (NSString *)stringFromHexString:(NSString *)hexString
{
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for(int i = 0; i < [hexString length] - 1; i += 2){
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
}




@end