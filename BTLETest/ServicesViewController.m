//
//  ServicesViewController.m
//  BTLETools
//
//  Created by Tijn Kooijmans on 10-04-12.
//  Copyright (c) 2012 Studio Sophisti. All rights reserved.
//

#import "ServicesViewController.h"
#import "BTLEDevice.h"
#import "CharacteristicViewController.h"
#import "CBService+Description.h"
#import "CBCharacteristic+Description.h"
#import "BTLETools-Swift.h"

@interface ServicesViewController ()

@end

@implementation ServicesViewController

@synthesize device;

- (void)dealloc {
    device.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.tableView];
}

- (void)updateTable {
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:@"connected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:@"disconnected" object:nil];
    
    self.title = @"Services";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    charVc = nil;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (loading || !device || device.state == CBPeripheralStateDisconnected) return 1;
    return [device.services count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (loading || !device || device.state == CBPeripheralStateDisconnected) return 1;
    
    CBService *service = [device.services objectAtIndex:section];
    
    return [service.characteristics count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (loading || !device || device.state == CBPeripheralStateDisconnected) return defaultCellHeight;
    
    CBService *service = [device.services objectAtIndex:indexPath.section];
    CBCharacteristic *characterstic = [service.characteristics objectAtIndex:indexPath.row];
    
    NSString *cellText = [NSString stringWithFormat:@"Value: %@\nAscii: %@", [characterstic hexString], [characterstic asciiString]];
    UIFont *cellFont = [UIFont systemFontOfSize:14];
    CGSize constraintSize = CGSizeMake(self.view.bounds.size.width - 40, MAXFLOAT);
    CGSize labelSize = [cellText boundingRectWithSize:constraintSize
                                                  options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               attributes:@{NSFontAttributeName:cellFont}
                                                  context:nil].size;
    return labelSize.height + defaultCellHeight - 13;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (loading) {
        static NSString *loadingIdentifier = @"LoadingCellIdentifier";
		
		UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:loadingIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										   reuseIdentifier:loadingIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
#ifdef TARGET_TV
			UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc]
                                                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            loadingView.tintColor = [UIColor lightGrayColor];
#else
            UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc]
                                                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
#endif
			loadingView.tag = 8;
			[cell.contentView addSubview:loadingView];
		}
        [(UIActivityIndicatorView*)[cell viewWithTag:8] setCenter: CGPointMake(self.view.frame.size.width / 2, defaultCellHeight / 2)];
        [(UIActivityIndicatorView*)[cell viewWithTag:8] startAnimating];
        
		return cell;
        
    } else if (!device || device.state == CBPeripheralStateDisconnected) {
        static NSString *nodDeviceIdentifier = @"NoDeviceCellIdentifier";
		
		UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:nodDeviceIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										   reuseIdentifier:nodDeviceIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = CELL_BOLD_TITLE_FONT;
            
            if (!device)
                cell.textLabel.text = @"No device connected";
            else
                cell.textLabel.text = @"Disconnected";
		}
		return cell;
    }
    
    CBService *service = [device.services objectAtIndex:indexPath.section];
    CBCharacteristic *characterstic = [service.characteristics objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"CharacteristicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
    cell.textLabel.text = [characterstic characteristicName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Value: %@\nAscii: %@", [characterstic hexString], [characterstic asciiString]];
    
    [cell.detailTextLabel sizeToFit];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (loading || device.state == CBPeripheralStateDisconnected) return @"";
    
    CBService *service = [device.services objectAtIndex:section];
    return [service serviceName];
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
 
    if (!device || device.state == CBPeripheralStateDisconnected || loading) return;
    
    CBService *service = [device.services objectAtIndex:indexPath.section];
    CBCharacteristic *characterstic = [service.characteristics objectAtIndex:indexPath.row];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:defaultStoryboard bundle:nil];
    charVc = [sb instantiateViewControllerWithIdentifier:@"characteristicViewController"];
    charVc.characteristic = characterstic;
    
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
    NSLog(@"Incoming: %@", [characteristic asciiString]);
    
    [[Logger shared] appendWithDevice:peripheral event:EventDataReceived service:characteristic.service characteristic:characteristic data:characteristic.value];
    
    [self.tableView reloadData];
    
    if (charVc) [charVc updatedValue];
}

@end
