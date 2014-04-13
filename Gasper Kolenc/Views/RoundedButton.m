//
//  ShopDropButon.m
//  Gasper Kolenc
//
//  Created by Gasper Kolenc on 06/04/14.
//  Copyright (c) 2014 Gasper Kolenc. All rights reserved.
//

#import "RoundedButton.h"

@implementation RoundedButton

- (void)drawRect:(CGRect)rect
{
    // Make a rounded button
    [self.normalColor setFill];
    if (self.highlighted || self.selected)[self.selectedColor setFill];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:rect.size.height / 2];
    [path fill];
    
    [self setTitleColor:self.textNormalColor forState:UIControlStateNormal];
    [self setTitleColor:self.textSelectedColor forState:UIControlStateHighlighted];
    [self setTitleColor:self.textSelectedColor forState:UIControlStateSelected];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [self setNeedsDisplay];
}

@end
