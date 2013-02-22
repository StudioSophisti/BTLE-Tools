//
//  BTLEDevice.m
//  BTLETools
//
//  Created by Tijn Kooijmans on 10-04-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BTLEDevice.h"

static BTLEDevice *connectedDevice__ = nil;

@implementation BTLEDevice

@synthesize peripheralRef, advertisementData, RSSI, manager;

+ (void)setConnectedDevice:(BTLEDevice*)device {
    if (connectedDevice__ != device) {
        [connectedDevice__ release];
        connectedDevice__ = [device retain];
    }
}

+ (BTLEDevice*)connectedDevice {
    return connectedDevice__;
}

- (void)dealloc {
    
    [peripheralRef release];
    [advertisementData release];
    [RSSI release];
    [manager release];
    
    [super dealloc];
}
@end
