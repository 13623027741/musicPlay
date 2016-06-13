//
//  MusicItem.m
//  MusicPlay
//
//  Created by kaidan on 16/5/30.
//  Copyright © 2016年 kaidan. All rights reserved.
//

#import "MusicItem.h"
#import "xTTBLEdata.h"
@implementation MusicItem

+(instancetype)creactMusicItemWithData:(NSString*)data{
    
    MusicItem* item = [[MusicItem alloc]init];
    
    NSString* str   = [data substringWithRange:NSMakeRange(0, 2)];
    NSString* temp  = [MusicItem ToHex:[xTTBLEdata ToHex:str]+1];
    NSString* temp1 = [data substringWithRange:NSMakeRange(2, 2)];
    if (temp.length == 2) {
        item.musicID = [NSString stringWithFormat:@"%@%@",temp,temp1];
    }else if(temp.length < 2){
        item.musicID = [NSString stringWithFormat:@"0%@%@",temp,temp1];
    }
    item.musicName = [item stringFromHexString:[data substringFromIndex:4]];
    
    return item;
}




- (NSString *)stringFromHexString:(NSString *)hexString {
    
    NSMutableArray* arr = [NSMutableArray array];
    for (int i = 0; i < hexString.length;) {
        NSString *tmp = [NSString stringWithFormat:@"\\u%@",[hexString substringWithRange:NSMakeRange(i+2, 2)]];
        tmp = [NSString stringWithFormat:@"%@%@",tmp,[hexString substringWithRange:NSMakeRange(i, 2)]];
        i += 4;
        [arr addObject:tmp];
    }
    
    return [xTTBLEdata replaceUnicode:[arr componentsJoinedByString:@""]];
    
}

#pragma mark - 十进制转十六进制
+ (NSString *)ToHex:(uint16_t)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    uint16_t ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
        
    }
    return str;
}

@end
