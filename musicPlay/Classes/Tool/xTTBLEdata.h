//
//  xTTBLEdata.h
//  BluetoothPlayer
//
//  Created by xTT on 14/11/4.
//  Copyright (c) 2014年 Bliss. All rights reserved.
//SPP_GET_TF_STATUS






#import <Foundation/Foundation.h>



typedef NS_ENUM(NSInteger, SPP_Command) {
    BTR_SWITCH_MODE                 = 1,    //切换系统工作模式     //
    
    BTR_SET_VOL                     = 6,    //设置音量          //
    BTR_GET_VOL                     = 7,    //得到当前音量
    
    BTR_SET_PLAY_STATUS             = 8,    //设置当前播放状态
    BTR_GET_PLAY_STATUS             = 9,    //得到当前播放状态
    BTR_SET_PLAY_MODE               =14,    //设置当前播放模式
    BTR_GET_PLAY_MODE               =15,    //得到当前的播放模式
    
    BTR_SET_PLAY_MUSICID            =17,    //设置当前播放的歌曲
    BTR_SET_LAST_NEXT               =18,    //设置上下曲
    BTR_GET_STDB_MODE               =19,    //得到系统工作模式
    
    BTR_SET_PLAY_BACK_FORWARD_START =30,    //设置音乐播放快进/快退开始
    BTR_SET_PLAY_BACK_FORWARD_STOP  =31,    //设置音乐播放快进/快退结束
    BTR_GET_PLAY_BACK_FORWARD_STATE =32,    //得到音乐播放快进/快退状态
    
    BTR_GET_A2DP_CONNECT_STATE      =39,    //获得A2DP状态
    
    BTR_REQUEST_DIRECTORY           =40,    //获取文件目录
    BTR_SEND_DIRECTORY              =41,    //文件目录
    
    BTR_USERDEFINE                  =42,    //自定义命令
    
    BTR_WOSHOU                      =100
};



@interface xTTBLEdata : NSObject


@property (nonatomic,strong) NSString *dBT;     //包头(1)
@property (nonatomic,strong) NSString *dBCD;    //包长度(2)
@property (nonatomic,strong) NSString *dMLBM;   //命令编码(1)
@property (nonatomic,strong) NSString *dMLXX;   //命令信息(1)


@property (nonatomic,strong) NSString *dYHSJCD; //用户数据总长度(2)(单命令或首包)


@property (nonatomic,strong) NSString *dBID;    //包ID(2)(分包命令)
@property (nonatomic,strong) NSString *dYHSJPY; //用户数据偏移(2)(分包命令)


@property (nonatomic,strong) NSString *dBQRBS;  //包确认标示符(1)(回应命令)(接收正确:0x55,数据出错:0xAA)


@property (nonatomic,strong) NSString *dYHSJ;   //用户数据
@property (nonatomic,strong) NSString *dJYH;    //校验和(2)
@property (nonatomic,strong) NSString *dBW;     //包尾(1)

@property (nonatomic,strong) NSString *allData;


@property (nonatomic,strong) NSMutableArray *arrCommand;

- (void)setBELData:(NSData *)data;
- (void)processBELData;


- (BOOL)isValidateData:(NSString *)str;
- (NSData *)getResponseDataWith:(BOOL)isValidate MLXX:(NSString *)mlxx MLBM:(NSString *)mlbm;

- (NSData *)getDataWithUserData:(NSString *)userData
                           type:(SPP_Command)type
                           MLXX:(NSString *)mlxx
                            BID:(NSString *)bid
                         YHSJPY:(NSString *)yhsjpy
                        YHSJZCD:(int)yhsjzcd;

+ (NSString *)intToLittle:(NSString *)str length:(int)length;
+ (NSString *)NSDataToByteTohex:(NSData *)data;//data转string(去转义符)

+ (NSData *)stringToByte:(NSString*)string;//string转data (加转义符)

+ (NSData *)stringToByte2:(NSString*)string;//string转data 

+ (NSString *)toBinary:(int)input;//10转2进制

+ (int)littleEndianModeToInt:(NSString *)str;

+ (NSString *)replaceUnicode:(NSString*)aUnicodeString;//Unicode转汉字
/**
 *  字符串转为16进制
 */
+ (NSString *)hexStringFromString:(NSString *)string;
/**
 *  16进制转10进制
 */
+ (int)ToHex:(NSString*)tmpid;

@end
