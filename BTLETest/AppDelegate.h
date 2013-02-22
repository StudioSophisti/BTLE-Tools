//
//  AppDelegate.h
//  BTLETest
//
//  Created by Tijn Kooijmans on 08-03-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class DevicesViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UISplitViewControllerDelegate>
{
}
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) DevicesViewController *viewController;

@end
