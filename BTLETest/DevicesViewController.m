//
//  DevicesViewController.m
//  BTLETools
//
//  Created by Tijn Kooijmans on 10-04-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DevicesViewController.h"
#import "DeviceViewController.h"
#import "ServicesViewController.h"
#import "BTLEDevice.h"

@interface DevicesViewController ()
- (void)actionScan;
@end

@implementation DevicesViewController

@synthesize servicesVc;

- (void)dealloc {
    
    [deviceVc release];
    [manager release];
    [devices release];
    [servicesVc release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        devices = [[NSMutableArray arrayWithCapacity:10] retain];
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"BT Smart Devices";
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionScan)] autorelease];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // interrupt pending connection attempts
    BTLEDevice *connectedDevice = [BTLEDevice connectedDevice];
    if (connectedDevice) {
        [connectedDevice.manager cancelPeripheralConnection:connectedDevice.peripheralRef];
    }
    
    [self actionScan];
}

#pragma mark - Actions

- (void)actionStopScanning {
    scanTimer = nil;
    
    scanning = NO;
    [manager stopScan];

    [self.tableView reloadData];
}

- (void)actionScan {
    
    
    if (manager.state == CBCentralManagerStatePoweredOff) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Bluetooth disabled" 
                                                         message:@"Please enable Bluetooth in your device settings to use this app." 
                                                        delegate:nil 
                                               cancelButtonTitle:@"OK" 
                                               otherButtonTitles:nil] autorelease];
        [alert show];
        return;
    }
    
    if (scanTimer) [scanTimer invalidate];
    
    scanning = YES;
    [devices removeAllObjects]; 
    
    [self.tableView reloadData];
    
    [manager stopScan];
    [manager scanForPeripheralsWithServices:nil options:nil];
    [manager retrieveConnectedPeripherals];
    
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(actionStopScanning) userInfo:nil repeats:NO];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int n = [devices count];
    if (scanning) n++;
    return n;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (scanning && indexPath.row == [devices count]) {
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
    }
    
    BTLEDevice *device = [devices objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"DeviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    }
    
    cell.textLabel.text = device.peripheralRef.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Signal strength: %d dB", device.RSSI.intValue];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BTLEDevice *device = [devices objectAtIndex:indexPath.row];
    
    if (deviceVc) [deviceVc release];
    deviceVc = [[DeviceViewController alloc] initWithDevice:device];
    
    [self.navigationController pushViewController:deviceVc animated:YES];
    
}

#pragma mark - CBCentralManagerDelegate


- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"Central manager changed state: %d", central.state);
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self actionScan];
    }
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    NSLog(@"%d periphirals retrieved", [peripherals count]);
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    
    for (CBPeripheral *peripheral in peripherals) {
        NSLog(@"Periphiral discovered: %@", peripheral.name);
        
        BTLEDevice *device = [[[BTLEDevice alloc] init] autorelease];
        device.peripheralRef = peripheral;
        device.RSSI = peripheral.RSSI;
        device.advertisementData = nil;
        device.manager = central;
        
        peripheral.delegate = self;
        [peripheral readRSSI];
        
        [devices addObject:device];
        
    }
    [self.tableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"Periphiral discovered: %@, signal strength: %d", peripheral.name, RSSI.intValue);
    
    BTLEDevice *device = [[[BTLEDevice alloc] init] autorelease];
    device.peripheralRef = peripheral;
    device.RSSI = RSSI;
    device.advertisementData = advertisementData;
    device.manager = central;
    
    [devices addObject:device];
    
    [self.tableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Periphiral connected: %@", peripheral.name);
    
    [deviceVc didConnect];
    
    if (!servicesVc) {
        servicesVc = [[ServicesViewController alloc] initWithDevice:peripheral];
    } else {
        servicesVc.device = peripheral;
        [servicesVc discoverServices];
    }
    
    if (!servicesVc.navigationController || servicesVc.navigationController == self.navigationController) // only push on iPhone
        [self.navigationController pushViewController:servicesVc animated:YES];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
     NSLog(@"Periphiral disconnected: %@", peripheral.name);
    
    [deviceVc didDisconnect];
    
    if ([self.navigationController.viewControllers count] > 2) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Device disconnected"
                                                         message:@""
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles: nil] autorelease];
        [alert show];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    if (servicesVc) {
        servicesVc.device = nil;
        [servicesVc updateTable];
        if (servicesVc.navigationController != self.navigationController) {
            [servicesVc.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Periphiral failed to connect: %@", peripheral.name);
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Failed to connect" 
                                                    message:error.localizedDescription 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                           otherButtonTitles:nil] autorelease];
    [alert show];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
  
    for (BTLEDevice *device in devices) {
        if (device.peripheralRef == peripheral) {
            device.RSSI = peripheral.RSSI;
        }
    }
    
    [self.tableView reloadData];
}

@end
