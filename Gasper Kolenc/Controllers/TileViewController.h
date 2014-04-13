//
//  TileViewController.h
//  Gasper Kolenc
//
//  Created by Gasper Kolenc on 06/04/14.
//  Copyright (c) 2014 Gasper Kolenc. All rights reserved.
//

#define kMaxMaskAlpha       0.8

#import <UIKit/UIKit.h>

@interface TileViewController : UIViewController

@property (strong, nonatomic) NSDictionary *tileDict;
@property NSUInteger page;

- (void)setMaskLayerOpacity:(CGFloat)opacity;
- (void)setOverlayImageOffset:(CGFloat)offset;

@end
