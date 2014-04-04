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
    NSDictionary *advertisementData;
    CBCentralManager *manager;
    
    NSString *advServices;
    NSString *brcData;
}

- (NSString*)advertisedServices;
- (int)txPower;
- (int)channel;
- (BOOL)isConnectable;
- (NSString*)name;
- (NSString*)broadcastData;

@property (nonatomic, strong) CBPeripheral *peripheralRef;
@property (nonatomic, strong) NSDictionary *advertisementData;
@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) NSNumber *RSSI;

@end
