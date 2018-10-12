//
//  WXBlueToothModule.h
//  WeexDemo
//
//  Created by zifan.zx on 2018/9/25.
//  Copyright © 2018年 taobao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WeexSDK/WeexSDK.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface WXBluetoothModule : NSObject<WXModuleProtocol,CBCentralManagerDelegate>

@end
