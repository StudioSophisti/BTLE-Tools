//
//  ServicesViewController.h
//  BTLETools
//
//  Created by Tijn Kooijmans on 10-04-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/Corebluetooth.h>

@class CharacteristicViewController;

@interface ServicesViewController : UITableViewController <CBPeripheralDelegate>
{
    CBPeripheral *device;
    BOOL loading;
    
    CharacteristicViewController *charVc;
}

@property (nonatomic, strong) CBPeripheral *device;

- (void)updateTable;
- (void)updateTitle;

@end
