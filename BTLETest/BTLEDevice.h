//
//  BTLEDevice.h
//  BTLETools
//
//  Created by Tijn Kooijmans on 10-04-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/Corebluetooth.h>

@interface BTLEDevice : NSObject
{
    CBPeripheral *peripheralRef;
    NSNumber *RSSI;
    NSDictionary *advertisementData;
    CBCentralManager *manager;
}

@property (nonatomic, retain) CBPeripheral *peripheralRef;
@property (nonatomic, retain) NSNumber *RSSI;
@property (nonatomic, retain) NSDictionary *advertisementData;
@property (nonatomic, retain) CBCentralManager *manager;

+ (void)setConnectedDevice:(BTLEDevice*)device;
+ (BTLEDevice*)connectedDevice;

@end
