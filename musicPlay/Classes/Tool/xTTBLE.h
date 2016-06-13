//
//  xTTBLE.h
//  BluetoothPlayer
//
//  Created by xTT on 14/11/4.
//  Copyright (c) 2014年 Bliss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "xTTBLEdata.h"

@interface xTTBLE : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    xTTBLEdata *BLEobj;
    
    CBCentralManager *scanManager;
    NSTimer *timeOut;
}

@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;

@property (strong,nonatomic) NSMutableArray *nDevices;

@property (strong ,nonatomic) CBCharacteristic *writeCharacteristic;
//@property (strong,nonatomic) NSMutableArray *nServices;
//@property (strong,nonatomic) NSMutableArray *nCharacteristics;

@property (strong,nonatomic) NSMutableArray *nWriteCharacteristics;
@property (assign,nonatomic) BOOL isConnect;

+ (xTTBLE *)getBLEObj;

- (void)chcekBluetoothPower;
- (void)scanClick;
- (void)connectClick:(CBPeripheral *)peripheral;

- (void)sendBLEData:(NSData *)data;

- (void)sendBLEuserData:(NSString *)userData type:(SPP_Command)type;
//自动登录
-(void)isLogin;

@end
