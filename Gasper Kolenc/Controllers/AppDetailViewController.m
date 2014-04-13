//
//  AppDetailViewController.m
//  Gasper Kolenc
//
//  Created by Gasper Kolenc on 07/04/14.
//  Copyright (c) 2014 Gasper Kolenc. All rights reserved.
//

#import <StoreKit/SKStoreProductViewController.h>
#import "AppDetailViewController.h"
#import "MFSideMenu.h"

@interface AppDetailViewController () <SKStoreProductViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *viewOnAppStoreBadge;

@end

@implementation AppDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _iconImageView.image = [UIImage imageNamed:[[_appDict objectForKey:@"Icon"] stringByAppendingString:@"Large"]];
    _titleLabel.text = [_appDict objectForKey:@"Title"];
    _descriptionTextView.text = [_appDict objectForKey:@"Description"];
    if (![_appDict objectForKey:@"AppID"]) _viewOnAppStoreBadge.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.menuContainerViewController setPanMode:MFSideMenuPanModeNone];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.menuContainerViewController setPanMode:MFSideMenuPanModeDefault];
}

#pragma mark - Store product delegate methods

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - User actions

- (IBAction)viewOnAppStore:(id)sender
{
    SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
    [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : [_appDict objectForKey:@"AppID"]} completionBlock:nil];
    storeProductViewController.delegate = self;
    [self presentViewController:storeProductViewController animated:YES completion:nil];
}

@end
