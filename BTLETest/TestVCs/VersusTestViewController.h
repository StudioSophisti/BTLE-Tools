//
//  VersusTestViewController.h
//  BTLETools
//
//  Created by Tijn Kooijmans on 26-11-12.
//
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
#import "CharacteristicDelegate.h"

@interface VersusTestViewController  : UIViewController <CharacteristicDelegate>

@end
