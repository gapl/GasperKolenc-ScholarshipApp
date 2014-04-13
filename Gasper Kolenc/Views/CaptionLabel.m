//
//  CaptionLabel.m
//  Gasper Kolenc
//
//  Created by Gasper Kolenc on 06/04/14.
//  Copyright (c) 2014 Gasper Kolenc. All rights reserved.
//

#import "CaptionLabel.h"

@implementation CaptionLabel

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Draw bubble
    CGRect bubbleRect = rect;
    bubbleRect.origin.y += kArrowWidth;
    bubbleRect.size.height -= kArrowWidth;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bubbleRect cornerRadius:6.0];
    [[UIColor colorWithWhite:0.97 alpha:1.0] setFill];
    [path fill];
    
    // Draw arrow
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, kArrowLeftOffset + kArrowHeight / 2, 0);
    CGContextAddLineToPoint(context, kArrowLeftOffset + kArrowHeight, kArrowWidth);
    CGContextAddLineToPoint(context, kArrowLeftOffset, kArrowWidth);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    [super drawRect:rect];
}

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {kArrowWidth, kArrowLeftOffset, 0, kArrowLeftOffset};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
