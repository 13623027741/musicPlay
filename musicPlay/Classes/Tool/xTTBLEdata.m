//
//  xTTBLEdata.m
//  BluetoothPlayer
//
//  Created by xTT on 14/11/4.
//  Copyright (c) 2014年 Bliss. All rights reserved.
//

//        0000 0000  单首 00

//        0000 0001  分首 01
//        0000 1001  分中 09
//        0001 0001  分结 11

//        0000 0010  回首 02
//        0000 1010  回中 0a
//        0001 0010  回结 12

// 任何命令 回应不做分包

#import "xTTBLEdata.h"
#import "AppDelegate.h"
#import "xTTBLE.h"
#import "MusicItem.h"

@implementation xTTBLEdata
{
    NSInteger index;
    NSString *musicName;
}

- (id)init{
    self = [super init];  // Call a designated initializer here.
    if (self) {
        _arrCommand = [[NSMutableArray alloc] init];
        musicName = @"";

    }
    return self;
}



- (void)removeAllData{
    _dBT = @"";
    _dBCD = @"";
    _dMLBM = @"";
    _dMLXX = @"";
    _dYHSJCD = @"";
    _dBID = @"";
    _dYHSJPY = @"";
    _dBQRBS = @"";
    _dYHSJ = @"";
    _dJYH = @"";
    _dBW = @"";
    _allData = @"";
}

//解析数据
- (void)setBELData:(NSData *)data{
    [self removeAllData];
    NSString *str = [xTTBLEdata NSDataToByteTohex:data];
    if (str.length > 10){
        _allData = str;
        
        _dBT    = [str substringWithRange:NSMakeRange(0, 2)];
        _dBCD   = [str substringWithRange:NSMakeRange(2, 4)];
        _dMLBM  = [str substringWithRange:NSMakeRange(6, 2)];
        _dMLXX  = [str substringWithRange:NSMakeRange(8, 2)];
        
        if ([_dMLXX isEqualToString:@"00"] || [_dMLXX isEqualToString:@"01"]) {
            _dYHSJCD    = [str substringWithRange:NSMakeRange(10, 4)];
            _dYHSJ      = [str substringWithRange:NSMakeRange(14, str.length - 20)];
        }else if ([_dMLXX isEqualToString:@"09"] || [_dMLXX isEqualToString:@"11"] || [_dMLXX isEqualToString:@"0a"] || [_dMLXX isEqualToString:@"12"]){
            _dYHSJPY    = [str substringWithRange:NSMakeRange(10, 4)];
            _dBID       = [str substringWithRange:NSMakeRange(14, 4)];
            _dYHSJ      = [str substringWithRange:NSMakeRange(14,  str.length - 20)];
        }else if ([_dMLXX isEqualToString:@"02"]){
            _dBQRBS  = [str substringWithRange:NSMakeRange(10, 2)];
            _dYHSJ   = [str substringWithRange:NSMakeRange(12, str.length - 18)];
        }
        
        _dJYH   = [str substringWithRange:NSMakeRange(str.length - 6, 4)];
        _dBW    = [str substringWithRange:NSMakeRange(str.length - 2, 2)];
    }
    NSLog(@"--用户数据[%@]----命令编码[%@]--",self.dYHSJ,self.dMLBM);
    
}

//处理数据
- (void)processBELData{
    if ([_dMLBM isEqualToString:@"02"]) {
        [self setSPPCommand];
    }else{
        NSLog(@"处理命令数据");
        [self processGetSPPCommand];
    }
}

//发送回应命令
- (NSData *)getResponseDataWith:(BOOL)isValidate MLXX:(NSString *)mlxx MLBM:(NSString *)mlbm
{
    //    11 0500 01  02 55 5d00  12
    NSMutableString *str = [NSMutableString string];
    
    [str appendString:@"11"];
    
    int i = 0;
    [str appendString:[xTTBLEdata intToLittle:[NSString stringWithFormat:@"%x",5] length:4]];//包长度
    i += 5;
    
    [str appendString:mlbm];
    i += [xTTBLEdata littleEndianModeToInt:mlbm];
    
    if ([mlxx isEqualToString:@"00"] || [mlxx isEqualToString:@"01"]) {
        [str appendString:@"02"];
        i += [xTTBLEdata littleEndianModeToInt:@"02"];
    }else if ([mlxx isEqualToString:@"09"]){
        [str appendString:@"0a"];
        i += [xTTBLEdata littleEndianModeToInt:@"0a"];
    }else if ([mlxx isEqualToString:@"11"]){
        [str appendString:@"12"];
        i += [xTTBLEdata littleEndianModeToInt:@"12"];
    }
    
    if (isValidate) {
        [str appendString:@"55"];
        i += [xTTBLEdata littleEndianModeToInt:@"55"];
    }else{
        [str appendString:@"aa"];
        i += [xTTBLEdata littleEndianModeToInt:@"aa"];
    }
    
    [str appendString:[xTTBLEdata intToLittle:[NSString stringWithFormat:@"%x",i] length:4]];//校验和
    
    [str appendString:@"12"];
    
    return [xTTBLEdata stringToByte:str];
}

//检测数据是否正确
- (BOOL)isValidateData:(NSString *)str
{
    if ([str hasPrefix:@"11"] && [str hasSuffix:@"12"]
        && [self getJYHint:str] == [xTTBLEdata littleEndianModeToInt:[str substringWithRange:NSMakeRange(str.length - 6, 4)]]) {
        return YES;
    }
    return NO;
}

//得到校验和
- (int)getJYHint:(NSString *)str{
    int jyh = 0;
    for (int i = 2; i < str.length - 6; i+=2) {
        jyh += [xTTBLEdata littleEndianModeToInt:[str substringWithRange:NSMakeRange(i, 2)]];
    }
    return jyh;
}

//得到命令总数和初始化
- (void)setSPPCommand{
    if (![[_arrCommand componentsJoinedByString:@""] isEqualToString:_dYHSJ]) {
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 0; i < _dYHSJ.length; i += 2) {
            [arr addObject:[_dYHSJ substringWithRange:NSMakeRange(i, 2)]];
            NSLog(@"--%@--",[_dYHSJ substringWithRange:NSMakeRange(i, 2)]);
        }
        
        [_arrCommand removeAllObjects];
        _arrCommand = [NSMutableArray arrayWithArray:arr];
    }
    [[xTTBLE getBLEObj] sendBLEuserData:@"" type:BTR_GET_PLAY_MODE];
    [[xTTBLE getBLEObj] sendBLEuserData:@"" type:BTR_GET_PLAY_STATUS];
    [[xTTBLE getBLEObj] sendBLEuserData:@"" type:BTR_GET_STDB_MODE];
    [[xTTBLE getBLEObj]sendBLEuserData:@"" type:BTR_GET_VOL];
}

//发送数据
- (NSData *)getDataWithUserData:(NSString *)userData
                           type:(SPP_Command)type
                           MLXX:(NSString *)mlxx
                            BID:(NSString *)bid
                         YHSJPY:(NSString *)yhsjpy
                        YHSJZCD:(int)yhsjzcd{
    NSMutableString *commandStr = [NSMutableString string];
    
    [commandStr appendString:@"11"];
    
    long jyh = 0;
    if ([mlxx isEqualToString:@"00"] ||[mlxx isEqualToString:@"01"]) {
        [commandStr appendString:[xTTBLEdata intToLittle:[NSString stringWithFormat:@"%lx",6 + userData.length / 2] length:4]];//包长度
    }else if ([mlxx isEqualToString:@"09"] || [mlxx isEqualToString:@"11"]){
        [commandStr appendString:[xTTBLEdata intToLittle:[NSString stringWithFormat:@"%lx",8 + userData.length / 2] length:4]];//包长度
    }
    
    if (type == 100) {
        [commandStr appendString:@"01"];
    }
    else{
        [commandStr appendString:_arrCommand[type - 1]];
    }
    
    [commandStr appendString:mlxx];
    
    if ([mlxx isEqualToString:@"00"] || [mlxx isEqualToString:@"01"]){
        [commandStr appendString:[xTTBLEdata intToLittle:[NSString stringWithFormat:@"%x",yhsjzcd] length:4]];//用户数据
    }
    
    if ([mlxx isEqualToString:@"09"] || [mlxx isEqualToString:@"11"]){
        [commandStr appendString:[xTTBLEdata intToLittle:bid length:4]];
        [commandStr appendString:[xTTBLEdata intToLittle:yhsjpy length:4]];
    }
    
    [commandStr appendString:userData];
    
    for (int i = 2; i < commandStr.length; i+=2) {
        jyh += [xTTBLEdata littleEndianModeToInt:[commandStr substringWithRange:NSMakeRange(i, 2)]];
    }
    
    [commandStr appendString:[xTTBLEdata intToLittle:[NSString stringWithFormat:@"%lx",jyh] length:4]];//校验和
    
    [commandStr appendString:@"12"];
    NSLog(@"--命令数据-%@--",commandStr);
    return [xTTBLEdata stringToByte:commandStr];
}

//处理命令数据
- (void)processGetSPPCommand{
    
    NSInteger count = [_arrCommand indexOfObject:_dMLBM] + 1;
    
    switch (count) {
        case 1://切换系统工作模式
        {
            
            NSLog(@"切换系统工作模式 : %@ ",_dYHSJ);
            if ([_dYHSJ isEqual:@"00"]) {

            }else if ([_dYHSJ isEqual:@"01"]){

                
            }else if ([_dYHSJ isEqual:@"03"]){
                
            }else if ([_dBQRBS isEqual:@"ac"] || [_dBQRBS isEqual:@"55"] || [_dBQRBS isEqual:@"ab"]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SWITCH_MODE" object:_dBQRBS];
            }else{
                
            }
        }
            break;
        case 2://得到指定序号的播放歌曲名
        {
            
//            NSLog(@"得到指定序号的单歌曲 --- %@  %ld",musicItem.musicName,musicItem.musicID);
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_REQUEST_MUSIC_NAME" object:nil];
        }
            break;
        case 3://发送指定序号的播放歌曲名
        {
            MusicItem* item = [MusicItem creactMusicItemWithData:_dYHSJ];
            NSLog(@"---歌曲名为[%@]---",item.musicName);
            [[NSNotificationCenter defaultCenter]postNotificationName:@"MusicItem" object:item];
        }
            break;
        case 6://设置音量
        {
            
        }
            break;
        case 7://得到当前音量
        {
            
        }
            break;
        case 8://设置当前播放状态
        {
            NSLog(@"设置当前播放状态[%@]",_dYHSJ);
            [[NSNotificationCenter defaultCenter]postNotificationName:@"isPlay" object:_dYHSJ];
            
        }
            break;
        case 9://得到当前播放状态
        {
            NSLog(@"得到当前的播放状态[%@]",_dYHSJ);
            [[NSNotificationCenter defaultCenter]postNotificationName:@"isPlay" object:_dYHSJ];
        }
            break;
        case 14://设置当前播放模式
        {
            [[xTTBLE getBLEObj] sendBLEuserData:@""
                                           type:BTR_GET_PLAY_MODE];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SET_PLAY_MODE" object:nil];
            NSLog(@"设置当前播放模式 %@",_dYHSJ);
            return;
        }
            break;
        case 15://得到当前的播放模式
        {
            
        }
            break;
        case 17://设置当前播放的歌曲
        {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SET_PLAY_MUSICID" object:nil];
            NSLog(@"设置当前播放的歌曲");
        }
            break;
        case 18://设置上下曲
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SET_LAST_NEXT" object:nil];
            NSLog(@"设置上下曲");
        }
            break;
        case 19://得到系统工作模式
        {
            NSLog(@"得到系统工作模式 %@",_dYHSJ);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_STDB_MODE" object:_dYHSJ];
        }
            break;
        case 39://获得A2DP状态
        {
            NSLog(@"获得A2DP状态-----[%@]-------",_dYHSJ);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_GET_A2DP_CONNECT_STATE" object:_dYHSJ];
        }
            break;
        case 40://获取文件目录
        {
            NSLog(@"获取文件目录%@",_dYHSJ);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_REQUEST_DIRECTORY" object:_dYHSJ];
        }
            break;
        case 41://得到文件目录
        {
            NSLog(@"得到文件目录-----%@",_dYHSJ);
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_SEND_DIRECTORY" object:folderItem];
        }
            break;
        case 42://自定义命令
        {
            NSLog(@"自定义命令---%@-",_dYHSJ);
            if ([_dYHSJ isEqualToString:@"53"]) {
                NSLog(@"断开所有蓝牙连接。。");
                [[NSNotificationCenter defaultCenter]postNotificationName:@"BLEAllDisconnect" object:nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"not_BTR_USERDEFINE" object:nil];
        }
            break;
        default:
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"not_SPP_TO_VIEW" object:nil];
}

//解析ASCII
- (NSString *)getNameWithASCII:(NSString *)str{
    NSString *tmp1 = @"";
    for (int i = 0 ; i< str.length; i+=2) {
        NSString *tmp2 = [NSString stringWithFormat:@"%c",[xTTBLEdata ToHex:[str substringWithRange:NSMakeRange(i, 2)]]];
        tmp1 = [NSString stringWithFormat:@"%@%@",tmp1,tmp2];
    }
    return tmp1;
}

//用户数转成小端模式
+ (NSString *)intToLittle:(NSString *)str length:(int)length{
    if (str.length % 2 == 1) {
        str = [NSString stringWithFormat:@"0%@",str];
    }
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < str.length / 2 ; i++) {
        [arr insertObject:[str substringWithRange:NSMakeRange(i * 2, 2)] atIndex:0];
    }
    NSString *tmp = [arr componentsJoinedByString:@""];
    if (tmp.length < length) {
        for (; tmp.length < length; ) {
            tmp = [NSString stringWithFormat:@"%@00",tmp];
        }
    }else if (tmp.length > length){
        tmp = [str substringWithRange:NSMakeRange(0, length)];
    }
    return tmp;
}

//小端转int
+ (int)littleEndianModeToInt:(NSString *)str{
    int count = 0;
    for (int i = 0; i < str.length / 2; i++) {
        int j = [self ToHex:[str substringWithRange:NSMakeRange(i * 2, 2)]];
        if (i != 0) {
            j *= pow(256, i);
        }
        count += j;
    }
    //    NSLog(@"%d",count);
    return count;
}

//Byte数组－>16进制数(去转义符)
+ (NSString *)NSDataToByteTohex:(NSData *)data{
    Byte *bytes = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    //    NSLog(@"hexStr:%@",hexStr);
    hexStr = [hexStr stringByReplacingOccurrencesOfString:@"1324" withString:@"11"];
    hexStr = [hexStr stringByReplacingOccurrencesOfString:@"1325" withString:@"12"];
    hexStr = [hexStr stringByReplacingOccurrencesOfString:@"1326" withString:@"13"];
    return hexStr;
}

//16进制转10进制
+ (int)ToHex:(NSString*)tmpid
{
    int int_ch;
    unichar hex_char1 = [tmpid characterAtIndex:0];
    
    int int_ch1;
    
    if(hex_char1 >= '0'&& hex_char1 <='9')
        int_ch1 = (hex_char1-48)*16;
    else if(hex_char1 >= 'A'&& hex_char1 <='F')
        int_ch1 = (hex_char1-55)*16;
    else
        int_ch1 = (hex_char1-87)*16;
    
    unichar hex_char2 = [tmpid characterAtIndex:1];
    int int_ch2;
    if(hex_char2 >= '0'&& hex_char2 <='9')
        int_ch2 = (hex_char2-48);
    else if(hex_char2 >= 'A'&& hex_char2 <='F')
        int_ch2 = hex_char2-55;
    else
        int_ch2 = hex_char2-87;
    
    int_ch = int_ch1+int_ch2;
    
    return int_ch;
}

//string转data (加转义符)
+ (NSData*)stringToByte:(NSString*)string
{
    NSString *hexString = [[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSInteger length = hexString.length;
    for (int i = 2; i < length - 2; i += 2) {
        if ([[hexString substringWithRange:NSMakeRange(i, 2)] isEqualToString:@"11"]) {
            hexString = [hexString stringByReplacingCharactersInRange:NSMakeRange(i, 2) withString:@"1324"];
            i += 2;
            length += 2;
        }else if([[hexString substringWithRange:NSMakeRange(i, 2)] isEqualToString:@"12"]){
            hexString = [hexString stringByReplacingCharactersInRange:NSMakeRange(i, 2) withString:@"1325"];
            i += 2;
            length += 2;
        }else if([[hexString substringWithRange:NSMakeRange(i, 2)] isEqualToString:@"13"]){
            hexString = [hexString stringByReplacingCharactersInRange:NSMakeRange(i, 2) withString:@"1326"];
            i += 2;
            length += 2;
        }
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes = [NSMutableData data];
    for (int i = 0; i < hexString.length; i++)
    {
        tempbyt[0] = [self ToHex:[hexString substringWithRange:NSMakeRange(i, 2)]];  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
        i++;
    }
    return bytes;
}

//10转2进制
+ (NSString *)toBinary:(int)input
{
    if (input == 1 || input == 0) {
        return [NSString stringWithFormat:@"%d", input];
    }
    else {
        return [NSString stringWithFormat:@"%@%d", [self toBinary:input / 2], input % 2];
    }
}

//Unicode转汉字
+ (NSString*) replaceUnicode:(NSString*)aUnicodeString
{
    NSString *tempStr1 = [aUnicodeString stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

//解析ASCII
+ (NSString *)getNameWithASCII:(NSString *)str{
    NSString *tmp1 = @"";
    for (int i = 0 ; i< str.length; i+=2) {
        NSString *tmp2 = [NSString stringWithFormat:@"%c",[xTTBLEdata ToHex:[str substringWithRange:NSMakeRange(i, 2)]]];
        tmp1 = [NSString stringWithFormat:@"%@%@",tmp1,tmp2];
    }
    return tmp1;
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
@end
