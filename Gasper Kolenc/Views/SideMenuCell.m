//
//  SideMenuCell.m
//  Gasper Kolenc
//
//  Created by Gasper Kolenc on 06/04/14.
//  Copyright (c) 2014 Gasper Kolenc. All rights reserved.
//

#import "SideMenuCell.h"

@implementation SideMenuCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected) {
        self.backgroundColor = kGreenColor;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.iconImageView.image = [UIImage imageNamed:[self.iconName stringByAppendingString:@"Selected"]];
    } else {
        self.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
        self.titleLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
        self.iconImageView.image = [UIImage imageNamed:self.iconName];
    }
}

@end
