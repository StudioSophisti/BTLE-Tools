//
//  DevicesViewController.h
//  BTLETools
//
//  Created by Tijn Kooijmans on 10-04-12.
//  Copyright (c) 2012 Studio Sophisti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/Corebluetooth.h>

@class DeviceViewController;
@class ServicesViewController;
@class BTLEDevice;

@interface DevicesViewController : UITableViewController <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager *manager;
    NSMutableArray *devices;
    BOOL scanning;
    NSTimer *scanTimer;
    
    DeviceViewController *deviceVc;
    ServicesViewController *servicesVc;
}

@end
