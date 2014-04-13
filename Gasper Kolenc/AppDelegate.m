//
//  AppDelegate.m
//  Gasper Kolenc
//
//  Created by Gasper Kolenc on 06/04/14.
//  Copyright (c) 2014 Gasper Kolenc. All rights reserved.
//

#import "AppDelegate.h"
#import "MFSideMenuContainerViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set UINavigationBar font
    [[UINavigationBar appearance] setTitleTextAttributes: @{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-DemiBold" size:16.0], NSForegroundColorAttributeName: [UIColor colorWithWhite:0.30f alpha:1.0]}];
    [[UIBarButtonItem appearance] setTitleTextAttributes: @{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Medium" size:16.0], NSForegroundColorAttributeName:kRedColor} forState:UIControlStateNormal];
    
    // Setup side menu
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    MFSideMenuContainerViewController *container = (MFSideMenuContainerViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"MainNavigationController"];
    UIViewController *leftSideMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"LeftSideMenuViewController"];
    
    [container setLeftMenuViewController:leftSideMenuViewController];
    [container setCenterViewController:navigationController];
    [container setMenuSlideAnimationEnabled:YES];
    
    return YES;
}

@end
