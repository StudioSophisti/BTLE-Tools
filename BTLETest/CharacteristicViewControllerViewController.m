//
//  CharacteristicViewControllerViewController.m
//  BTLETools
//
//  Created by Tijn Kooijmans on 11-04-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CharacteristicViewControllerViewController.h"
#import "CBCharacteristic+Description.h"
#import "VersusTestViewController.h"

@interface CharacteristicViewControllerViewController ()

@end

@implementation CharacteristicViewControllerViewController

- (id)initWithCharacteristic:(CBCharacteristic*)theChar {
    self = [super initWithNibName:@"CharacteristicViewControllerViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        characteristic = theChar;
    }
    return self;
}

- (void)dealloc {
    delegate = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Characteristic";
    
    /*self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
    */
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionReload:)] autorelease];
   
    
    lblName.text = [characteristic characteristicName];
    lblValue.text = [NSString stringWithFormat:@"Value: %@\nAscii: %@", [characteristic hexString], [characteristic asciiString]];
    
    requestTime = [[NSDate date] timeIntervalSince1970];
    [characteristic.service.peripheral readValueForCharacteristic:characteristic];
    
    
    NSMutableString *propertiesString = [NSMutableString stringWithString:@"Properties:  \n"];
    if (characteristic.properties & CBCharacteristicPropertyRead) 
        [propertiesString appendString:@"Readable, "];
    if (characteristic.properties & CBCharacteristicPropertyWrite) 
        [propertiesString appendString:@"Writable, "];
    if (characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) 
        [propertiesString appendString:@"Writable without response, "];
    if (characteristic.properties & CBCharacteristicPropertyNotify) 
        [propertiesString appendString:@"Notifying, "];
    if (characteristic.properties & CBCharacteristicPropertyIndicate) 
        [propertiesString appendString:@"Indicating, "];
    if (characteristic.properties & CBCharacteristicPropertyExtendedProperties) 
        [propertiesString appendString:@"Extended properties, "];
    if (characteristic.properties & CBCharacteristicPropertyBroadcast) 
        [propertiesString appendString:@"Broadcasting, "];
    if (characteristic.properties & CBCharacteristicPropertyAuthenticatedSignedWrites) 
        [propertiesString appendString:@"Authenticated Signed Writes, "];
    
    [propertiesString appendString:@"\b\b"];
    lblProperties.text = propertiesString;
    [lblProperties sizeToFit];
    
    if ((characteristic.properties &CBCharacteristicPropertyWrite) ||
        (characteristic.properties &CBCharacteristicPropertyWriteWithoutResponse)) {
        vwWrite.hidden = NO;
    } else {
        vwWrite.hidden = YES;
        
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    delegate = nil;
    liveUpdate = NO;
    [btnLive setTitle:@"Live updating" forState:UIControlStateNormal];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)updatedValue {
    
    double lag = [[NSDate date] timeIntervalSince1970]-requestTime;
    lblLatency.text = [NSString stringWithFormat:@"Latency: %.3f s", lag];
    
    lblValue.text = [NSString stringWithFormat:@"Value: %@\nAscii: %@", [characteristic hexString], [characteristic asciiString]];
    
    if (liveUpdate) {
        requestTime = [[NSDate date] timeIntervalSince1970];
        [characteristic.service.peripheral readValueForCharacteristic:characteristic];
    }
    
    if (delegate && [delegate respondsToSelector:@selector(characteristic:changedWithData:)]) {
        [delegate characteristic:characteristic changedWithData:characteristic.value];
    }
}

#pragma mark - Actions

- (void)showActions:(id)sender  {
    
    VersusTestViewController *versusVC = [[[VersusTestViewController alloc] init] autorelease];
    delegate = versusVC;
    
    //if (!liveUpdate) [self actionLiveUpdate:nil];
    
    [self.navigationController pushViewController:versusVC animated:YES];
}

- (IBAction)actionLiveUpdate:(id)sender {

    liveUpdate = !liveUpdate;
    
    if (liveUpdate) {
        
        //self.navigationItem.rightBarButtonItem.enabled = NO;
        
        requestTime = [[NSDate date] timeIntervalSince1970];
        [characteristic.service.peripheral readValueForCharacteristic:characteristic];
        
        [btnLive setTitle:@"Stop updating" forState:UIControlStateNormal];
        
    } else {
        
        //self.navigationItem.rightBarButtonItem.enabled = YES;
        
        [btnLive setTitle:@"Live updating" forState:UIControlStateNormal];
        
    }
}

- (IBAction)actionReload:(id)sender {
    
    requestTime = [[NSDate date] timeIntervalSince1970];
    [characteristic.service.peripheral readValueForCharacteristic:characteristic];
}

- (IBAction)actionSend:(id)sender {
    NSArray *byteStrings = [txtSend.text componentsSeparatedByString:@":"];
    
    NSMutableData *data = [NSMutableData dataWithCapacity:[byteStrings count]];
    
    BOOL failed = NO;
    if ([byteStrings count] == 0) failed = YES;
    
    for (NSString *byteString in byteStrings) {
        if ([byteString length] != 2)  {
            failed = YES;
            break;
        }
        unsigned int a = 0;
        NSScanner *scanner = [[NSScanner alloc] initWithString:byteString];
        if ([scanner scanHexInt:&a]) {
            uint8_t b = (uint8_t)a;
            [data appendBytes:&b length:1];
        }
        [scanner release];
    }
    
    if (!failed) {
        if (characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse)
            [characteristic.service.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
        else if (characteristic.properties & CBCharacteristicPropertyWrite)
            [characteristic.service.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        
        [txtSend resignFirstResponder];
        
    } else {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Format error" 
                                   message:@"Please match the following formatting: 'ff:ff:ff:ff:...'" 
                                  delegate:nil 
                         cancelButtonTitle:@"OK" 
                          otherButtonTitles:nil] autorelease];
        [alert show];
    }
}

#pragma mark - UITextFieldDelegate 

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

@end
