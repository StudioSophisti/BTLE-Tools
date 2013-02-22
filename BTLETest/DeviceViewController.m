//
//  DeviceViewController.m
//  BTLETools
//
//  Created by Tijn Kooijmans on 10-04-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DeviceViewController.h"
#import "BTLEDevice.h"

@interface DeviceViewController ()

@end

@implementation DeviceViewController

- (id)initWithDevice:(BTLEDevice*)theDevice {
    self = [super initWithNibName:@"DeviceViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        device = [theDevice retain];
    }
    return self;
}

- (void)dealloc {
    [device release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Device Data";
    
    lblName.text = device.peripheralRef.name;
    
    lblUUID.text = [NSString stringWithFormat:@"Device UUID: %@", device.peripheralRef.UUID];
    //lblUUID.text = [NSString stringWithFormat:@"Device UUID: %@", CFUUIDCreateString(NULL, device.peripheralRef.UUID)];
    
    [lblUUID sizeToFit];
    
    lblTxPower.text = [NSString stringWithFormat:@"TX Power: %d", 
                       [[device.advertisementData objectForKey:CBAdvertisementDataTxPowerLevelKey] intValue]];

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if (device.peripheralRef.isConnected) {
        
        [btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didConnect {
    
    [actConnect stopAnimating];
    actConnect.hidden = YES;
    
    [btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
}

- (void)didDisconnect {
    
    [actConnect stopAnimating];
    actConnect.hidden = YES;
    
    [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
}


#pragma mark - Actions

- (IBAction)actionConnect:(id)sender {
    
    if (!actConnect.hidden) return;

    if (device.peripheralRef.isConnected) {
        
        // when connected, disconnect
        [BTLEDevice setConnectedDevice:nil];
        [device.manager cancelPeripheralConnection:device.peripheralRef];
        
    } else {
        
        [BTLEDevice setConnectedDevice:device];
        [device.manager connectPeripheral:device.peripheralRef options:nil];
    }
    
    actConnect.hidden = NO;
    [actConnect startAnimating];
    
}

@end
