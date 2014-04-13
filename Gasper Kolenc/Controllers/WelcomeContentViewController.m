//
//  WelcomeContentViewController.m
//  Gasper Kolenc
//
//  Created by Gasper Kolenc on 07/04/14.
//  Copyright (c) 2014 Gasper Kolenc. All rights reserved.
//

#import "WelcomeContentViewController.h"

@interface WelcomeContentViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property CGRect labelFrame;

@end

@implementation WelcomeContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _iconImageView.image = [UIImage imageNamed:_iconImage];
    _descriptionLabel.text = _descriptionText;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _labelFrame = _descriptionLabel.frame;
}

- (void)refreshForOffset:(CGFloat)offset
{
    CGRect frame = _labelFrame;
    frame.origin.x -= offset / 2;
    _descriptionLabel.frame = frame;
}

@end
