//
//  ServicesViewController.h
//  BTLETools
//
//  Created by Tijn Kooijmans on 10-04-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/Corebluetooth.h>

@class CharacteristicViewControllerViewController;

@interface ServicesViewController : UITableViewController <CBPeripheralDelegate>
{
    CBPeripheral *device;
    BOOL loading;
    
    CharacteristicViewControllerViewController *charVc;
}

@property (nonatomic, retain) CBPeripheral *device;

- (id)initWithDevice:(CBPeripheral*)theDevice;
- (void)discoverServices;
- (void)updateTable;

@end
