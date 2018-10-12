//
//  WXBlueToothModule.m
//  WeexDemo
//
//  Created by zifan.zx on 2018/9/25.
//  Copyright © 2018年 taobao. All rights reserved.
//

#import "WXBluetoothModule.h"

@interface WXBluetoothModule()
@property(nonatomic, strong)CBCentralManager* centralManager;
@property(nonatomic, strong)dispatch_queue_t bluetoothQueue;
@property (nonatomic, assign) NSTimeInterval scanExpireTime;
@property(strong) NSTimer * stopTimer;
@property (strong)WXModuleKeepAliveCallback callback;
@property (strong)NSArray * scanResult;
@end

@implementation WXBluetoothModule

WX_EXPORT_METHOD(@selector(requestDevice:callback:))

- (instancetype)init {
    if (self = [super init]) {
        self.bluetoothQueue = dispatch_queue_create(object_getClassName([self class]), DISPATCH_QUEUE_SERIAL);
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:self.bluetoothQueue options:nil];
    }
    return self;
}

- (void)requestDevice:(NSDictionary*)options callback:(WXKeepAliveCallback)callback
{
    self.scanResult = [NSArray new];
    self.callback = callback;
    NSArray<CBUUID*>* uuids = [self getUUIDFromOptions:options];
    if (self.centralManager.state == CBManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:uuids options:nil];
        [self beginScanTime];
    }
    
}

- (void)beginScanTime
{
    self.scanExpireTime = [NSDate timeIntervalSinceReferenceDate];
    if (!self.stopTimer) {
        __weak typeof(self) weakSelf = self;
        self.stopTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.stopTimer = nil;
            if ([strongSelf isScanTimeExpire]) {
                // callback data;
                if (strongSelf.callback) {
                    strongSelf.callback(strongSelf.scanResult, YES);
                }
            } else {
                [strongSelf beginScanTime];
            }
        }];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    [self updateScanTime];
    NSMutableArray * scanResult = [self.scanResult mutableCopy];
    NSDictionary * peripheralDevice = @{@"id":peripheral.identifier.UUIDString,
                                        @"name":peripheral.name?:@"",
                                        @"gatt":@{@"connected":@(peripheral.state == CBPeripheralStateConnected)
                                                  },
                                        @"uuids":peripheral.services?:@[]
                                        };
    [scanResult addObject:peripheralDevice];
    self.scanResult = [scanResult copy];
}
- (BOOL)isScanTimeExpire {
    if (self.scanExpireTime <= 0) {
        return NO;
    }
    if (self.scanExpireTime > [[NSDate date] timeIntervalSince1970]) {
        return NO;
    }
    return YES;
}

- (void)updateScanTime
{
    self.scanExpireTime = [[NSDate date] timeIntervalSince1970] + 4;
}

- (NSArray<CBUUID*>*)getUUIDFromOptions:(NSDictionary*)options
{
    NSMutableArray * uuidStrings = [NSMutableArray new];
    NSMutableArray<CBUUID*>* uuids = nil;
    NSArray* filters = options[@"filters"];
    
    for (NSDictionary* filter in filters) {
        if (!(filter[@"services"])) {
            continue;
        }
        if ([filter[@"services"] isKindOfClass:[NSArray class]]) {
            [uuidStrings addObjectsFromArray:(NSArray*)filter[@"services"]];
        } else {
            [uuidStrings addObject:filter[@"services"]];
        }
    }
    if (0 == [uuidStrings count]) {
        return uuids;
    }
    uuids = [NSMutableArray array];
    for (id uuid in uuidStrings) {
        NSString * uuidStringValue = nil;
        if ([uuid isKindOfClass:[NSNumber class]]) {
            uuidStringValue = [uuid stringValue];
            
        } else if ([uuid isKindOfClass:[NSString class]]) {
            uuidStringValue = uuid;
        } else {
            WXLogError(@"invalid type for uuid %@", uuid);
            continue;
        }
        CBUUID * uuid = nil;
        @try {
            uuid = [CBUUID UUIDWithString:uuidStringValue];
            [uuids addObject:uuid];
        }@catch(NSException* exception) {
            WXLogError(@"%@", exception);
        }
    }
    
    return uuids;
}


- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    if (@available(iOS 10.0, *))
    {
        switch (central.state)
        {
            case CBManagerStateUnauthorized:
            {
                [self.centralManager stopScan];
                
                break;
            }
            case CBManagerStatePoweredOff:
            {
                [self.centralManager stopScan];
                break;
            }
            case CBManagerStatePoweredOn:
            {
                // 这里之后交给统一权限管理
//                [self scan];
                
                break;
            }
            case CBManagerStateResetting:
            case CBManagerStateUnsupported:
            default:
            {
                [self.centralManager stopScan];
                break;
            }
        }
    }
    else
    {
        switch (central.state)
        {
            case CBCentralManagerStateUnauthorized:
            {
                [self.centralManager stopScan];
//                [self didDisableScan];
                break;
            }
            case CBCentralManagerStatePoweredOff:
            {
                [self.centralManager stopScan];
//                [self didDisableScan];
                break;
            }
            case CBCentralManagerStatePoweredOn:
            {
//                [self scan];
                [self.centralManager stopScan];
                break;
            }
            case CBCentralManagerStateResetting:
            case CBCentralManagerStateUnsupported:
            default:
            {
                [self.centralManager stopScan];
//                [self didDisableScan];
                break;
            }
        }
    }
}

@end
