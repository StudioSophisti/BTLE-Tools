//
//  DeviceViewController.m
//  BTLETools
//
//  Created by Tijn Kooijmans on 10-04-12.
//  Copyright (c) 2012 Studio Sophisti. All rights reserved.
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
    
#ifndef TARGET_TV
    self.title = @"Device Data";
#endif
    
    [self updateLabels];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViews) name:@"connected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViews) name:@"disconnected" object:nil];
}

- (void)updateLabels {
    lblName.text = [_device name];
    lblUUID.text = [NSString stringWithFormat:@"UUID: %@", [_device.peripheralRef.identifier UUIDString]];
    lblServices.text = [_device advertisedServices];
    lblData.text = [_device broadcastData];
    
    [self updateRSSI];
}

- (void)updateRSSI {
    
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendFormat:@"RSSI: %d", [_device.RSSI intValue]];
    if ([_device txPower] > -1) {
        [str appendFormat:@", TX Power: %d", [_device txPower]];
    }
    if ([_device channel] > -1) {
        [str appendFormat:@", Channel: %d", [_device channel]];
    }
    lblTxPower.text = str;
}

- (void)updateViews {
    
    [self updateLabels];
    
    if (_device.peripheralRef.state == CBPeripheralStateConnected) {
        
        connectCell.accessoryView = nil;
        connectCell.textLabel.text = @"Disconnect";
        
    } else if (_device.peripheralRef.state == CBPeripheralStateConnecting) {
        
#ifdef TARGET_TV
        connectCell.accessoryView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        connectCell.accessoryView .tintColor = [UIColor lightGrayColor];
#else
        connectCell.accessoryView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
#endif
        [(UIActivityIndicatorView*)connectCell.accessoryView startAnimating];
        connectCell.textLabel.text = @"Connecting...";
        
    } else if (![_device isConnectable]) {
        
        connectCell.textLabel.text = @"Not Connectable";
        
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
    if (!_device) return 0;
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) return 2;
    else if (section == 1 && _device.peripheralRef.state == CBPeripheralStateConnected) return 2;
    else if (section == 1) return 1;
    else return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        
        ServicesViewController *servicesVc = nil;
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:defaultStoryboard bundle:nil];
        servicesVc = [sb instantiateViewControllerWithIdentifier:@"servicesViewController"];
            
        [self.navigationController pushViewController:servicesVc animated:YES];        
    
        servicesVc.device = _device.peripheralRef;
        _device.peripheralRef.delegate = servicesVc;
        [_device.peripheralRef discoverServices:nil];
        
    } else if (indexPath.section == 1 && indexPath.row == 0 && [_device isConnectable]) {
        [self actionConnect:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        CGSize constraintSize = CGSizeMake(self.view.bounds.size.width - 40, MAXFLOAT);
        CGSize labelSize = [lblUUID.text boundingRectWithSize:constraintSize
                                                  options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               attributes:@{NSFontAttributeName:CELL_TITLE_FONT}
                                                  context:nil].size;
        return labelSize.height + 20;
        
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        CGSize constraintSize = CGSizeMake(self.view.bounds.size.width - 40, MAXFLOAT);
        CGSize labelSize = [lblServices.text boundingRectWithSize:constraintSize
                                                  options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               attributes:@{NSFontAttributeName:CELL_TITLE_FONT}
                                                  context:nil].size;
        return labelSize.height + 20;
        
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        CGSize constraintSize = CGSizeMake(self.view.bounds.size.width - 40, MAXFLOAT);
        CGSize labelSize = [lblData.text boundingRectWithSize:constraintSize
                                                  options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               attributes:@{NSFontAttributeName:CELL_TITLE_FONT}
                                                  context:nil].size;
        return labelSize.height + 20;
        
    } else {
        return defaultCellHeight;
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
