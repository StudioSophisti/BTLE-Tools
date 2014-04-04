//
//  DevicesViewController.m
//  BTLETools
//
//  Created by Tijn Kooijmans on 10-04-12.
//  Copyright (c) 2012 Studio Sophisti. All rights reserved.
//

#import "DevicesViewController.h"
#import "DeviceViewController.h"
#import "ServicesViewController.h"
#import "BTLEDevice.h"

@interface DevicesViewController ()
- (void)actionScan;
@end

@implementation DevicesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    devices = [NSMutableArray arrayWithCapacity:10];

    self.title = @"BLE Scan Results";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionScan)];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateRSSI) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionScan)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    deviceVc = (DeviceViewController*)[[(UINavigationController*)[self.splitViewController.viewControllers objectAtIndex:1]
                                            viewControllers] objectAtIndex:0];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

#pragma mark - Actions

- (void)actionStopScanning {
    scanTimer = nil;
    
    scanning = NO;
    [manager stopScan];

    [self.tableView reloadData];
}

- (BTLEDevice*)addPeripheral:(CBPeripheral*)peripheral {
    BTLEDevice *device = [[BTLEDevice alloc] init];
    device.peripheralRef = peripheral;
    device.manager = manager;
    
    peripheral.delegate = self;
    
    [devices addObject:device];
    return device;
}

- (void)updateRSSI {
    for (BTLEDevice *device in devices) {
        if (device.peripheralRef.state == CBPeripheralStateConnected) {
            [device.peripheralRef readRSSI];
            device.RSSI = device.peripheralRef.RSSI;
        }
    }
    [deviceVc updateRSSI];
    [self.tableView reloadData];
}

- (void)actionScan {    
    
    if (manager.state == CBCentralManagerStatePoweredOff) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bluetooth disabled" 
                                                         message:@"Please enable Bluetooth in your device settings to use this app." 
                                                        delegate:nil 
                                               cancelButtonTitle:@"OK" 
                                               otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (scanTimer) [scanTimer invalidate];
    
    scanning = YES;
    
    NSMutableArray *newDevices = [[NSMutableArray alloc] initWithCapacity:10];
    for (BTLEDevice *device in devices) {
        if (device.peripheralRef.state != CBPeripheralStateDisconnected)
            [newDevices addObject:device];
    }
    devices = newDevices;
    
    [self.tableView reloadData];
    
    [manager stopScan];
    
    //check if other apps are connected
    [manager retrieveConnectedPeripherals];
        
    [manager scanForPeripheralsWithServices:nil options:nil];
    
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(actionStopScanning) userInfo:nil repeats:NO];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger n = [devices count];
    if (scanning) n++;
    return n;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (scanning && indexPath.row == [devices count]) {
        static NSString *loadingIdentifier = @"LoadingCellIdentifier";
		
		UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:loadingIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										   reuseIdentifier:loadingIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc]
                                                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
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
    
    cell.textLabel.text = [device name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Signal strength: %d dB", device.RSSI.intValue];
    
    if ([device channel] > -1) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, channel %d", cell.detailTextLabel.text, [device channel]];
    }
    
    if (device.peripheralRef.state == CBPeripheralStateConnected) {
        cell.imageView.image = [UIImage imageNamed:@"bt_icon.png"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"bt_icon_grey.png"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (IS_IPAD) {
        [[self.splitViewController.viewControllers objectAtIndex:1] setViewControllers:[NSArray arrayWithObject:deviceVc]];
        deviceVc.device = [devices objectAtIndex:indexPath.row];
        [deviceVc updateViews];
        deviceVc.title = [deviceVc.device name];
    } else {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        deviceVc  = [sb instantiateViewControllerWithIdentifier:@"deviceViewController"];
        deviceVc.device = [devices objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:deviceVc animated:YES];
    }
    
}


#pragma mark - CBCentralManagerDelegate


- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"Central manager changed state: %ld", central.state);
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self actionScan];
    }
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    NSLog(@"%ld periphirals retrieved", [peripherals count]);
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    
    for (CBPeripheral *peripheral in peripherals) {
        NSLog(@"Periphiral discovered: %@", peripheral.name);
        
        BOOL found = NO;
        for (BTLEDevice *device in devices) {
            if ([[device.peripheralRef.identifier UUIDString] isEqualToString:[peripheral.identifier UUIDString]]) {
                found = YES;
            }
        }
        if (!found)
            [self addPeripheral:peripheral];
        
    }
    [self.tableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"Periphiral discovered: %@, signal strength: %d", peripheral.name, RSSI.intValue);
    
    for (BTLEDevice *device in devices) {
        if ([[device.peripheralRef.identifier UUIDString] isEqualToString:[peripheral.identifier UUIDString]]) {
            return;
        }
    }
    
    BTLEDevice *device = [self addPeripheral:peripheral];
    device.advertisementData = advertisementData;
    device.RSSI = RSSI;
    
    [self.tableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Periphiral connected: %@", peripheral.name);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connection_changed" object:nil];
        
    [self.tableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
     NSLog(@"Periphiral disconnected: %@", peripheral.name);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connection_changed" object:nil];
    
    [self.tableView reloadData];
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Periphiral failed to connect: %@", peripheral.name);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to connect" 
                                                    message:error.localizedDescription 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                           otherButtonTitles:nil];
    [alert show];
}

@end
