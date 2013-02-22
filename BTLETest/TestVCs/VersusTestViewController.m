//
//  VersusTestViewController.m
//  BTLETools
//
//  Created by Tijn Kooijmans on 26-11-12.
//
//

#import "VersusTestViewController.h"

@interface VersusTestViewController ()

@end

@implementation VersusTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)characteristic:(CBCharacteristic*)characteristic changedWithData:(NSData*)data {
    
    uint8_t *bytes = (uint8_t*)[data bytes];
    
    if (data.length >= 12) {
        /*A*/
        if (bytes[8] & 0x02) [self.view viewWithTag:1].backgroundColor = [UIColor blueColor];
        else if (bytes[11] & 0x02) [self.view viewWithTag:1].backgroundColor = [UIColor blueColor];
        else if (bytes[5] & 0x02) [self.view viewWithTag:1].backgroundColor = [UIColor blueColor];
        else if (bytes[2] & 0x02) [self.view viewWithTag:1].backgroundColor = [UIColor blueColor];
        else [self.view viewWithTag:1].backgroundColor = [UIColor lightGrayColor];
        /*B*/
        if (bytes[8] & 0x01) [self.view viewWithTag:2].backgroundColor = [UIColor blueColor];
        else if (bytes[11] & 0x01) [self.view viewWithTag:2].backgroundColor = [UIColor blueColor];
        else if (bytes[5] & 0x01) [self.view viewWithTag:2].backgroundColor = [UIColor blueColor];
        else if (bytes[2] & 0x01) [self.view viewWithTag:2].backgroundColor = [UIColor blueColor];
        else [self.view viewWithTag:2].backgroundColor = [UIColor lightGrayColor];
        /*C*/
        if (bytes[7] & 0x01) [self.view viewWithTag:3].backgroundColor = [UIColor blueColor];
        else if (bytes[10] & 0x01) [self.view viewWithTag:3].backgroundColor = [UIColor blueColor];
        else if (bytes[4] & 0x01) [self.view viewWithTag:3].backgroundColor = [UIColor blueColor];
        else if (bytes[1] & 0x01) [self.view viewWithTag:3].backgroundColor = [UIColor blueColor];
        else [self.view viewWithTag:3].backgroundColor = [UIColor lightGrayColor];
        /*D*/
        if (bytes[6] & 0x01) [self.view viewWithTag:4].backgroundColor = [UIColor blueColor];
        else if (bytes[9] & 0x01) [self.view viewWithTag:4].backgroundColor = [UIColor blueColor];
        else if (bytes[3] & 0x01) [self.view viewWithTag:4].backgroundColor = [UIColor blueColor];
        else if (bytes[0] & 0x01) [self.view viewWithTag:4].backgroundColor = [UIColor blueColor];
        else [self.view viewWithTag:4].backgroundColor = [UIColor lightGrayColor];
        /*Action*/
        if (bytes[7] & 0x02) [self.view viewWithTag:5].backgroundColor = [UIColor blueColor];
        else if (bytes[10] & 0x02) [self.view viewWithTag:5].backgroundColor = [UIColor blueColor];
        else if (bytes[4] & 0x02) [self.view viewWithTag:5].backgroundColor = [UIColor blueColor];
        else if (bytes[1] & 0x02) [self.view viewWithTag:5].backgroundColor = [UIColor blueColor];
        else [self.view viewWithTag:5].backgroundColor = [UIColor lightGrayColor];
        /*Up*/
        if (bytes[6] & 0x02) [self.view viewWithTag:6].backgroundColor = [UIColor blueColor];
        else if (bytes[9] & 0x02) [self.view viewWithTag:6].backgroundColor = [UIColor blueColor];
        else if (bytes[3] & 0x02) [self.view viewWithTag:6].backgroundColor = [UIColor blueColor];
        else if (bytes[0] & 0x02) [self.view viewWithTag:6].backgroundColor = [UIColor blueColor];
        else [self.view viewWithTag:6].backgroundColor = [UIColor lightGrayColor];
        /*Left*/
        if (bytes[8] & 0x04) [self.view viewWithTag:7].backgroundColor = [UIColor blueColor];
        else if (bytes[11] & 0x04) [self.view viewWithTag:7].backgroundColor = [UIColor blueColor];
        else if (bytes[5] & 0x04) [self.view viewWithTag:7].backgroundColor = [UIColor blueColor];
        else if (bytes[2] & 0x04) [self.view viewWithTag:7].backgroundColor = [UIColor blueColor];
        else [self.view viewWithTag:7].backgroundColor = [UIColor lightGrayColor];
        /*Down*/
        if (bytes[7] & 0x04) [self.view viewWithTag:8].backgroundColor = [UIColor blueColor];
        else if (bytes[10] & 0x04) [self.view viewWithTag:8].backgroundColor = [UIColor blueColor];
        else if (bytes[4] & 0x04) [self.view viewWithTag:8].backgroundColor = [UIColor blueColor];
        else if (bytes[1] & 0x04) [self.view viewWithTag:8].backgroundColor = [UIColor blueColor];
        else [self.view viewWithTag:8].backgroundColor = [UIColor lightGrayColor];
        /*Right*/
        if (bytes[6] & 0x04) [self.view viewWithTag:9].backgroundColor = [UIColor blueColor];
        else if (bytes[9] & 0x04) [self.view viewWithTag:9].backgroundColor = [UIColor blueColor];
        else if (bytes[3] & 0x04) [self.view viewWithTag:9].backgroundColor = [UIColor blueColor];
        else if (bytes[0] & 0x04) [self.view viewWithTag:9].backgroundColor = [UIColor blueColor];
        else [self.view viewWithTag:9].backgroundColor = [UIColor lightGrayColor];
    }
}

@end
