//
//  BTLEDevice.m
//  BTLETools
//
//  Created by Tijn Kooijmans on 10-04-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BTLEDevice.h"
#import "CBUUID+String.h"

@implementation BTLEDevice

@synthesize peripheralRef, advertisementData, manager;

- (int)txPower {
    if ([advertisementData objectForKey:CBAdvertisementDataTxPowerLevelKey]) {
        return [[advertisementData objectForKey:CBAdvertisementDataTxPowerLevelKey] intValue];
    }
    return -1;
}

- (NSString*)advertisedServices {
    if (advServices) return advServices;
    
    NSMutableString *str = [[NSMutableString alloc] init];
    if ([advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey]) {
        
        [str appendString:@"Services: "];
        NSArray *services = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
        if ([services count]) {
            for (CBUUID *serviceUUID in services) {
                [str appendFormat:@"%@, ", [serviceUUID representativeString]];
            }
            [str appendString:@"xxx"];
            [str replaceOccurrencesOfString:@", xxx" withString:@"" options:0 range:NSMakeRange(0, [str length])];
            
            advServices = str;
            
        } else {
            advServices = @"No advertised services";
        }
    } else {
        advServices = @"No advertised services";
    }
    return advServices;
}

- (int)channel {
    if ([advertisementData objectForKey:@"kCBAdvDataChannel"])
        return [[advertisementData objectForKey:@"kCBAdvDataChannel"] intValue];
    
    return -1;
}

- (BOOL)isConnectable {
    return [[advertisementData objectForKey:CBAdvertisementDataIsConnectable] boolValue];
}

- (NSString*)name {
    NSString *deviceName = nil;
    
    if ((deviceName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey]) && [deviceName length]) {
        return deviceName;
    } else if ((deviceName = [peripheralRef name]) && [deviceName length]) {
        return deviceName;
    }
    return @"<no name>";
}

- (NSString*)broadcastData {
    if (brcData) return brcData;
    
    if ([advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey]) {
        NSString *raw = [[advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey] description];
        raw = [raw stringByReplacingOccurrencesOfString:@"<" withString:@""];
        raw = [raw stringByReplacingOccurrencesOfString:@">" withString:@""];
        brcData = [NSString stringWithFormat:@"Broadcasted data: 0x%@", raw];
    } else {
        brcData = @"No broadcasted data";
    }
    return brcData;
}

@end
