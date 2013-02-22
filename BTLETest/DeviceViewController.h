//
//  DeviceViewController.h
//  BTLETools
//
//  Created by Tijn Kooijmans on 10-04-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTLEDevice;

@interface DeviceViewController : UIViewController
{
    IBOutlet UILabel *lblName, *lblTxPower, *lblUUID, *lblServices;
    IBOutlet UIActivityIndicatorView *actConnect;
    IBOutlet UIButton *btnConnect;
    BTLEDevice *device;
}

- (id)initWithDevice:(BTLEDevice*)theDevice;

- (IBAction)actionConnect:(id)sender;
- (void)didConnect;
- (void)didDisconnect;

@end
