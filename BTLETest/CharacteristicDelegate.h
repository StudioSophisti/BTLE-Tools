//
//  CharacteristicDelegate.h
//  BTLETools
//
//  Created by Tijn Kooijmans on 26-11-12.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/Corebluetooth.h>

@protocol CharacteristicDelegate <NSObject>
- (void)characteristic:(CBCharacteristic*)characteristic changedWithData:(NSData*)data;
@end
