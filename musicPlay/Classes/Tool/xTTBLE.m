//
//  xTTBLE.m
//  BluetoothPlayer
//
//  Created by xTT on 14/11/4.
//  Copyright (c) 2014年 Bliss. All rights reserved.
//

#import "xTTBLE.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"


@interface xTTBLE ()


@end

@implementation xTTBLE{
}



- (id)init {
    self = [super init];  // Call a designated initializer here.
    if (self) {
        _manager    = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        _nDevices   = [[NSMutableArray alloc] init];
        BLEobj      = [[xTTBLEdata alloc] init];
        _isConnect  = NO;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeVolume:) name:@"not_BTR_GET_VOL" object:nil];
    }
    return self;
}


+ (xTTBLE *)getBLEObj{
    static xTTBLE *xTTble;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        xTTble = [[xTTBLE alloc] init];
    });
    return xTTble;
}

//开始查看服务，蓝牙开启
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            
            [self isLogin];
            break;
        case CBCentralManagerStatePoweredOff:
            
            if(_peripheral){
                [self.manager cancelPeripheralConnection:_peripheral];
            }
            _isConnect = NO;
            _peripheral = nil;
            break;
        default:
            break;
    }
    if (central == scanManager) {
        scanManager = nil;
    }
}

- (void)chcekBluetoothPower{
    scanManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

- (void)scanClick
{
    [_manager stopScan];
    [_manager scanForPeripheralsWithServices:nil options:nil];
    
}


#pragma mark - 自动登录
-(void)isLogin{
    if (!_peripheral){
        [self scanClick];
    }
}

//查到外设后，停止扫描
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
//    NSLog(@"%@",[NSString stringWithFormat:@"已发现 peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI, peripheral.identifier, advertisementData]);
    
}

-(void)connectClick:(CBPeripheral *)peripheral
{
    _isConnect = NO;
    if (_peripheral && _peripheral.state == CBPeripheralStateDisconnected) {
        [_manager cancelPeripheralConnection:_peripheral];
    }
    _peripheral = nil;

    [_manager stopScan];
    [_manager connectPeripheral:peripheral options:nil];
    
}


//连接外设成功，开始发现服务
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"%@",[NSString stringWithFormat:@"成功连接 peripheral: %@ with UUID: %@",peripheral,peripheral.identifier]);
    _peripheral = peripheral;
    
    [_peripheral setDelegate:self];
    [_peripheral discoverServices:nil];
    
}

//连接外设失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"外设连接失败---");
    [_manager cancelPeripheralConnection:peripheral];
    [_manager connectPeripheral:peripheral options:nil];
}
//外设断开
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
    if (error) {
        [self.manager cancelPeripheralConnection:_peripheral];
        _peripheral = nil;
        [self isLogin];
        NSLog(@"连接断开-error[%@]--",error);
    }else{
        NSLog(@"正常断开");
        
    }
}

//已发现服务,开始发现特征
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *s in peripheral.services) {
        if (![s.UUID.UUIDString isEqualToString:@"180A"]) {
            [peripheral discoverCharacteristics:nil forService:s];
            
        }
    }
}

//已搜索到Characteristics
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"-------------------------------");
//    NSLog(@"%@",[NSString stringWithFormat:@"服务 UUID: %@ (%@)",service.UUID.data,service.UUID.UUIDString]);
    
    for (CBCharacteristic *c in service.characteristics) {
//        DLog(@"特征 UUID: %@ : %@  :  %@",c.UUID.UUIDString,c.UUID,c.value);
    }
}

- (void)configurationDeivce{
    [[xTTBLE getBLEObj] sendBLEuserData:@"" type:BTR_WOSHOU];
}

//获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"read = %@",characteristic.value);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"readData" object:characteristic.value];
    
    if (characteristic.value.length > 5 && _writeCharacteristic) {
        [self getBLEDataWithValue:characteristic.value];
        
        
    }
}

- (BOOL)getBLEDataWithValue:(NSData *)value{
    
    NSString *str = [xTTBLEdata NSDataToByteTohex:value];
    
    NSString *mlxx = [str substringWithRange:NSMakeRange(8, 2)];
    BOOL isValidate = [BLEobj isValidateData:str];
    if (![mlxx isEqualToString:@"02"] && ![mlxx isEqualToString:@"0a"] && ![mlxx isEqualToString:@"12"]) {
        [self sendBLEData:[BLEobj getResponseDataWith:isValidate MLXX:mlxx MLBM:[str substringWithRange:NSMakeRange(6, 2)]]];
    }
    if (isValidate) {
        if ([[str substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"]) {
            _isConnect = isValidate;
        }else{
            [BLEobj setBELData:value];
            [BLEobj processBELData];
        }
    }
    return isValidate;
}


- (void)sendBLEuserData:(NSString *)userData type:(SPP_Command)type
{
    
    NSString *tmp;
    int length  = 100;
    if (userData.length < length) {
        NSData* data = [BLEobj getDataWithUserData:userData type:type MLXX:@"00" BID:@"" YHSJPY:@"" YHSJZCD:userData.length /2];
        [self sendBLEData:data];
    }else{
        NSString *mlxx;
        for (int i = 0; i * length < userData.length; i++) {
            if ((i+1) * length < userData.length) {
                tmp = [userData substringWithRange:NSMakeRange(i * length, length)];
                if (i == 0) {
                    mlxx = @"01";
                    NSData* data = [BLEobj getDataWithUserData:tmp type:type
                                                          MLXX:mlxx BID:@"" YHSJPY:@""
                                                       YHSJZCD:userData.length / 2];
                    [self sendBLEData:data];
                }else{
                    mlxx = @"09";
                    NSString *bid = [xTTBLEdata intToLittle:[NSString stringWithFormat:@"%x",i] length:4];
                    NSString *yhsjpy = [xTTBLEdata intToLittle:[NSString stringWithFormat:@"%x",i * length / 2] length:4];
                    [self sendBLEData:[BLEobj getDataWithUserData:tmp type:type
                                                             MLXX:mlxx BID:bid
                                                           YHSJPY:yhsjpy
                                                          YHSJZCD:userData.length / 2]];
                }
            }else{
                tmp = [userData substringWithRange:NSMakeRange(i * length, userData.length - i * length)];
                mlxx = @"11";
                NSString *bid = [xTTBLEdata intToLittle:[NSString stringWithFormat:@"%x",i] length:4];
                NSString *yhsjpy = [xTTBLEdata intToLittle:[NSString stringWithFormat:@"%x",i * length / 2] length:4];
                NSData* data = [BLEobj getDataWithUserData:tmp type:type
                                                      MLXX:mlxx BID:bid
                                                    YHSJPY:yhsjpy
                                                   YHSJZCD:userData.length / 2];
                [self sendBLEData:data];
            }
        }
    }
}

-(void)sendBLEData:(NSData *)data
{
    NSLog(@"send data ====== %@",data);
    if(!data) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sendData" object:data];
    [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

//用于检测中心向外设写数据是否成功
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
//        NSLog(@"%@",[NSString stringWithFormat:@"特征 UUID: %@ (%@) %@",characteristic.UUID.data,characteristic.UUID,characteristic.value]);
        NSLog(@"=======%@",error.userInfo);
        if (![xTTBLE getBLEObj].peripheral || [xTTBLE getBLEObj].peripheral.state == CBPeripheralStateDisconnected){
            [[xTTBLE getBLEObj] scanClick];
        }
    }else{
//        NSLog(@"发送数据成功");
    }
}


/**
 *  在连接后得到系统音量
 */
-(void)changeVolume:(NSNotification*)noti{
    if (_isConnect) {
        NSLog(@"--连接成功了吗----");
        
    }
}

@end
