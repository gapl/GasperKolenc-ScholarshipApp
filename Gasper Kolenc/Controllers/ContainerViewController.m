//
//  ContainerViewController.m
//  Gasper Kolenc
//
//  Created by Gasper Kolenc on 07/04/14.
//  Copyright (c) 2014 Gasper Kolenc. All rights reserved.
//

#import "ContainerViewController.h"
#import "MFSideMenu.h"

@interface ContainerViewController ()

@end

@implementation ContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Use original image in navigation bar
    self.navigationItem.leftBarButtonItem.image = [self.navigationItem.leftBarButtonItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.menuContainerViewController setPanMode:MFSideMenuPanModeDefault];
}

#pragma mark - User actions

- (IBAction)toggleSideMenu:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

@end
