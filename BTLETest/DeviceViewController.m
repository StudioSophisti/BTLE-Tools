//
//  DeviceViewController.m
//  BTLETools
//
//  Created by Tijn Kooijmans on 10-04-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DeviceViewController.h"
#import "BTLEDevice.h"
#import "ServicesViewController.h"

@interface DeviceViewController ()

@end

@implementation DeviceViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Device Data";

    lblName.text = _device.peripheralRef.name;
    
    lblUUID.text = [NSString stringWithFormat:@"Device UUID: %@", [_device.peripheralRef.identifier UUIDString]];
    
    lblTxPower.text = [NSString stringWithFormat:@"TX Power: %d",
                       [[_device.advertisementData objectForKey:CBAdvertisementDataTxPowerLevelKey] intValue]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViews) name:@"connection_changed" object:nil];
}

- (void)updateViews {
    
    if (_device.peripheralRef.state == CBPeripheralStateConnected) {
        
        connectCell.accessoryView = nil;
        connectCell.textLabel.text = @"Disconnect";
        
    } else if (_device.peripheralRef.state == CBPeripheralStateConnecting) {
        
        connectCell.accessoryView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [(UIActivityIndicatorView*)connectCell.accessoryView startAnimating];
        connectCell.textLabel.text = @"Connecting";
        
    } else {
        
        connectCell.accessoryView = nil;
        connectCell.textLabel.text = @"Connect";
    }
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateViews];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1 && _device.peripheralRef.state == CBPeripheralStateConnected) return 2;
    else if (section == 1) return 1;
    else return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        
        ServicesViewController *servicesVc = nil;
        
        if (IS_IPAD) {
            [[self.splitViewController.viewControllers objectAtIndex:1] popToRootViewControllerAnimated:YES];
            servicesVc = (ServicesViewController*)[[(UINavigationController*)[self.splitViewController.viewControllers objectAtIndex:1]
                                                    viewControllers] objectAtIndex:0];
            
        } else {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            servicesVc = [sb instantiateViewControllerWithIdentifier:@"servicesViewController"];
            
            [self.navigationController pushViewController:servicesVc animated:YES];
        }
    
        servicesVc.device = _device.peripheralRef;
        _device.peripheralRef.delegate = servicesVc;
        [_device.peripheralRef discoverServices:nil];
        [servicesVc updateTitle];
        
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [self actionConnect:nil];
    }
}

#pragma mark - Actions

- (IBAction)actionConnect:(id)sender {
    
    if (_device.peripheralRef.state != CBPeripheralStateDisconnected) {
        [_device.manager cancelPeripheralConnection:_device.peripheralRef];
        
    } else {
        [_device.manager connectPeripheral:_device.peripheralRef options:nil];
    }
    
    [self updateViews];
}

@end
