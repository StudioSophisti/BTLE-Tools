//
//  ServicesViewController.m
//  BTLETools
//
//  Created by Tijn Kooijmans on 10-04-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServicesViewController.h"
#import "BTLEDevice.h"
#import "CharacteristicViewControllerViewController.h"
#import "CBService+Description.h"
#import "CBCharacteristic+Description.h"

@interface ServicesViewController ()

@end

@implementation ServicesViewController

@synthesize device;

- (void)dealloc {
    [device release];
    [charVc release];
    
    [super dealloc];
}

- (id)initWithDevice:(CBPeripheral *)theDevice {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        device = [theDevice retain];
    }
    return self;
}

- (void)updateTable {
    [self.tableView reloadData];
}

- (void)discoverServices {
    
    if (device) {
        loading = YES;
        
        device.delegate = self;
        [device discoverServices:nil];
    }
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Services";
    
    [self discoverServices];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    
    if (charVc) [charVc release];
    charVc = nil;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (loading || !device) return 1;
    return [device.services count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (loading || !device) return 1;
    
    CBService *service = [device.services objectAtIndex:section];
    
    return [service.characteristics count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (loading || !device) return 44;
    
    CBService *service = [device.services objectAtIndex:indexPath.section];
    CBCharacteristic *characterstic = [service.characteristics objectAtIndex:indexPath.row];
    
    NSString *cellText = [NSString stringWithFormat:@"Value: %@\nAscii: %@", [characterstic hexString], [characterstic asciiString]];
    UIFont *cellFont = [UIFont systemFontOfSize:14];
    CGSize constraintSize = CGSizeMake(self.view.bounds.size.width - 40, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return labelSize.height + 44 - 13;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (loading) {
        static NSString *loadingIdentifier = @"LoadingCellIdentifier";
		
		UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:loadingIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										   reuseIdentifier:loadingIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			UIActivityIndicatorView *loadingView = [[[UIActivityIndicatorView alloc]
                                                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
			loadingView.tag = 8;
			[cell.contentView addSubview:loadingView];
		}
        [(UIActivityIndicatorView*)[cell viewWithTag:8] setCenter: CGPointMake(self.view.frame.size.width / 2, 22)];
        [(UIActivityIndicatorView*)[cell viewWithTag:8] startAnimating];
        
		return cell;
        
    } else if (!device) {
        static NSString *nodDeviceIdentifier = @"NoDeviceCellIdentifier";
		
		UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:nodDeviceIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										   reuseIdentifier:nodDeviceIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.text = @"No device connected";
		}
		return cell;
    }
    
    CBService *service = [device.services objectAtIndex:indexPath.section];
    CBCharacteristic *characterstic = [service.characteristics objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"CharacteristicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
    }
    
    cell.textLabel.text = [characterstic characteristicName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Value: %@\nAscii: %@", [characterstic hexString], [characterstic asciiString]];
    
    [cell.detailTextLabel sizeToFit];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    
    if (loading) return @"";
    
    CBService *service = [device.services objectAtIndex:section];
    return [service serviceName];
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBService *service = [device.services objectAtIndex:indexPath.section];
    CBCharacteristic *characterstic = [service.characteristics objectAtIndex:indexPath.row];
    
    charVc = [[CharacteristicViewControllerViewController alloc] initWithCharacteristic:characterstic];
    
    [self.navigationController pushViewController:charVc animated:YES];
}

#pragma mark - CBPeripheralDelegate


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    //NSLog(@"Services dicovered for peripheral %@:", peripheral.name);
    
    for (CBService *service in peripheral.services) {
        NSLog(@"%@", service.UUID);
     
        [peripheral discoverCharacteristics:nil forService:service];
    }
    
    loading = NO;
    
    [self.tableView reloadData];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    //NSLog(@"characteristics dicovered for service %@:", service.UUID);
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"%@", characteristic.UUID);
        
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        [peripheral readValueForCharacteristic:characteristic];
        
    }
    
    [self.tableView reloadData];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //NSLog(@"Updated value for characteristic %@: %@", characteristic.UUID, characteristic.value);
    
    [self.tableView reloadData];
    
    if (charVc) [charVc updatedValue];
}

@end
