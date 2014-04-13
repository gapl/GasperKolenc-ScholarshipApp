//
//  MeDetailCell.m
//  Gasper Kolenc
//
//  Created by Gasper Kolenc on 07/04/14.
//  Copyright (c) 2014 Gasper Kolenc. All rights reserved.
//

#import "MeDetailCell.h"

@implementation MeDetailCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = kGreenColor;
        [self setSelectedBackgroundView:bgColorView];
    }
    return self;
}

@end
