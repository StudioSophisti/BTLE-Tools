//
//  CharacteristicViewControllerViewController.m
//  BTLETools
//
//  Created by Tijn Kooijmans on 11-04-12.
//  Copyright (c) 2012 Studio Sophisti. All rights reserved.
//

#import "CharacteristicViewController.h"
#import "CBCharacteristic+Description.h"

@interface CharacteristicViewController ()

@end

@implementation CharacteristicViewController

@synthesize characteristic;

- (void)dealloc {
    delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Characteristic";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionReload:)];
   
    
    lblName.text = [characteristic characteristicName];
    lblValue.text = [NSString stringWithFormat:@"Value (HEX): %@", [characteristic hexString]];
    lblAscii.text = [NSString stringWithFormat:@"Value (ASCII): %@", [characteristic asciiString]];
    
    requestTime = [[NSDate date] timeIntervalSince1970];
    [characteristic.service.peripheral readValueForCharacteristic:characteristic];
    
    
    NSMutableString *propertiesString = [NSMutableString stringWithString:@"Properties: "];
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
    
    [propertiesString appendString:@"xxx"];
    [propertiesString replaceOccurrencesOfString:@", xxx" withString:@"" options:0 range:NSMakeRange(0, [propertiesString length])];
    lblProperties.text = propertiesString;
    [lblProperties sizeToFit];
    
    if ((characteristic.properties &CBCharacteristicPropertyWrite) ||
        (characteristic.properties &CBCharacteristicPropertyWriteWithoutResponse)) {
        vwWrite.hidden = NO;
    } else {
        vwWrite.hidden = YES;
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnected) name:@"disconnected" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    delegate = nil;
    liveUpdate = NO;
    [lblLive setText:@"Live updating"];
}

- (void)disconnected {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updatedValue {
    
    double lag = [[NSDate date] timeIntervalSince1970]-requestTime;
    lblLatency.text = [NSString stringWithFormat:@"Read Latency: %.3f s", lag];
    
    lblValue.text = [NSString stringWithFormat:@"Value (HEX): %@", [characteristic hexString]];
    lblAscii.text = [NSString stringWithFormat:@"Value (ASCII): %@", [characteristic asciiString]];
    
    if (liveUpdate) {
        requestTime = [[NSDate date] timeIntervalSince1970];
        [characteristic.service.peripheral readValueForCharacteristic:characteristic];
    }
    
    if (delegate && [delegate respondsToSelector:@selector(characteristic:changedWithData:)]) {
        [delegate characteristic:characteristic changedWithData:characteristic.value];
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (characteristic.service.peripheral.state == CBPeripheralStateDisconnected) {
        return 1;
    }
    
    if ((characteristic.properties &CBCharacteristicPropertyWrite) ||
        (characteristic.properties &CBCharacteristicPropertyWriteWithoutResponse)) {
        return 3;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (characteristic.service.peripheral.state == CBPeripheralStateDisconnected) {
        return 1;
    }
    
    if (section == 0) return 4;
    else return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        
        [self actionLiveUpdate:nil];
        
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        
        [self actionSend:nil];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section > 0) return defaultCellHeight;
    
    else if (indexPath.row == 0) {
        UIFont *cellFont = [UIFont boldSystemFontOfSize:18];
        CGSize constraintSize = CGSizeMake(self.view.bounds.size.width - 40, MAXFLOAT);
        CGSize labelSize = [lblName.text boundingRectWithSize:constraintSize
                                                  options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               attributes:@{NSFontAttributeName:cellFont}
                                                  context:nil].size;
        return labelSize.height + 20;
    
    } else if (indexPath.row == 1) {
        CGSize constraintSize = CGSizeMake(self.view.bounds.size.width - 40, MAXFLOAT);
        CGSize labelSize = [lblValue.text boundingRectWithSize:constraintSize
                                                      options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                   attributes:@{NSFontAttributeName:CELL_TITLE_FONT}
                                                      context:nil].size;
        return labelSize.height + 20;
        
    } else if (indexPath.row == 2) {
        UIFont *cellFont = [UIFont systemFontOfSize:16];
        CGSize constraintSize = CGSizeMake(self.view.bounds.size.width - 40, MAXFLOAT);
        CGSize labelSize = [lblAscii.text boundingRectWithSize:constraintSize
                                                      options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                   attributes:@{NSFontAttributeName:cellFont}
                                                      context:nil].size;
        return labelSize.height + 20;
        
    } else if (indexPath.row == 3) {
        UIFont *cellFont = [UIFont systemFontOfSize:16];
        CGSize constraintSize = CGSizeMake(self.view.bounds.size.width - 40, MAXFLOAT);
        CGSize labelSize = [lblProperties.text boundingRectWithSize:constraintSize
                                                      options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                   attributes:@{NSFontAttributeName:cellFont}
                                                      context:nil].size;
        return labelSize.height + 20;
        
    } else {
        return defaultCellHeight;
    }
    
    
}

#pragma mark - Actions

- (IBAction)actionLiveUpdate:(id)sender {

    liveUpdate = !liveUpdate;
    
    if (liveUpdate) {
        
        //self.navigationItem.rightBarButtonItem.enabled = NO;
        
        requestTime = [[NSDate date] timeIntervalSince1970];
        [characteristic.service.peripheral readValueForCharacteristic:characteristic];
        
        [lblLive setText:@"Stop updating"];
        
    } else {
        
        //self.navigationItem.rightBarButtonItem.enabled = YES;
        
        [lblLive setText:@"Live updating"];
        
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
    }
    
    if (!failed) {
        if (characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse)
            [characteristic.service.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
        else if (characteristic.properties & CBCharacteristicPropertyWrite)
            [characteristic.service.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        
        [txtSend resignFirstResponder];
        
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Format error" message:@"Please match the following formatting: 'ff:ff:ff:ff:...'"  preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:true completion:nil];
    }
}

#pragma mark - UITextFieldDelegate 

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

@end
