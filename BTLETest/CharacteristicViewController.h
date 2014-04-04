//
//  CharacteristicViewControllerViewController.h
//  BTLETools
//
//  Created by Tijn Kooijmans on 11-04-12.
//  Copyright (c) 2012 Studio Sophisti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/Corebluetooth.h>
#import "CharacteristicDelegate.h"

@interface CharacteristicViewController : UITableViewController <UITextFieldDelegate>
{
    IBOutlet UILabel *lblName, *lblValue, *lblAscii, *lblLatency, *lblProperties;
    IBOutlet UILabel *lblLive;
    IBOutlet UITextField *txtSend;
    IBOutlet UIView *vwWrite;
        
    BOOL liveUpdate;
    
    double requestTime;
    
    id<CharacteristicDelegate> delegate;
    
    CBCharacteristic *characteristic;
}

@property (nonatomic,strong) CBCharacteristic *characteristic;

- (void)updatedValue;

- (IBAction)actionLiveUpdate:(id)sender;
- (IBAction)actionSend:(id)sender;

@end
