//
//  AppDelegate.m
//  BTLETest
//
//  Created by Tijn Kooijmans on 08-03-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ServicesViewController.h"
#import "DevicesViewController.h"
#import "BTLEDevice.h"
#import "FlurryAnalytics.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

void uncaughtExceptionHandler(NSException *exception);

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAnalytics logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [FlurryAnalytics startSession:@"GQTXKK8BGM7N9NFJFM78"];    
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitVc = [[[UISplitViewController alloc] init] autorelease];
     
        ServicesViewController *servicesVc = [[[ServicesViewController alloc] init] autorelease];
        DevicesViewController *devicesVc = [[[DevicesViewController alloc] init] autorelease];
        devicesVc.servicesVc = servicesVc;
        
        UINavigationController *vcLeft = [[[UINavigationController alloc] initWithRootViewController:devicesVc] autorelease];
        UINavigationController *vcRight = [[[UINavigationController alloc] initWithRootViewController:servicesVc] autorelease];
        
        splitVc.viewControllers = [NSArray arrayWithObjects:vcLeft, vcRight, nil];
        splitVc.delegate = self;
        
        self.window.rootViewController = splitVc;
        
    } else {
        self.viewController = [[[DevicesViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        UINavigationController *naviVC = [[[UINavigationController alloc] initWithRootViewController:self.viewController] autorelease];
        self.window.rootViewController = naviVC;
    }
    
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    if (![UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [(UINavigationController*)self.window.rootViewController popToRootViewControllerAnimated:NO];
    }
    
    /* disconnect device to save battery
    BTLEDevice *connectedDevice = [BTLEDevice connectedDevice];
    if (connectedDevice && connectedDevice.peripheralRef.isConnected) {
        [connectedDevice.manager cancelPeripheralConnection:connectedDevice.peripheralRef];
    }*/
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - UISplitViewControllerDeletate

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    
    barButtonItem.title = @"Devices";
    [[svc.viewControllers objectAtIndex:1] topViewController].navigationItem.leftBarButtonItem = barButtonItem;
    
}

@end
