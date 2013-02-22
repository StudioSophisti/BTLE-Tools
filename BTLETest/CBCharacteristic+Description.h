//
//  CBCharacteristic+Description.h
//  BTLETools
//
//  Created by Tijn Kooijmans on 14-11-12.
//
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBCharacteristic (Description)

- (NSString*)characteristicName;
- (NSString*)hexString;
- (NSString*)asciiString;

@end
