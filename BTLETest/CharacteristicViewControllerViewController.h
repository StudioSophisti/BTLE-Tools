//
//  CharacteristicViewControllerViewController.h
//  BTLETools
//
//  Created by Tijn Kooijmans on 11-04-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/Corebluetooth.h>
#import "CharacteristicDelegate.h"

@interface CharacteristicViewControllerViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UILabel *lblName, *lblValue, *lblLatency, *lblProperties;
    IBOutlet UIButton *btnLive;
    IBOutlet UITextField *txtSend;
    IBOutlet UIView *vwWrite;
    
    CBCharacteristic *characteristic;
    
    BOOL liveUpdate;
    
    double requestTime;
    
    id<CharacteristicDelegate> delegate;
}

- (id)initWithCharacteristic:(CBCharacteristic*)theChar;
- (void)updatedValue;

- (IBAction)actionLiveUpdate:(id)sender;
- (IBAction)actionSend:(id)sender;

@end
