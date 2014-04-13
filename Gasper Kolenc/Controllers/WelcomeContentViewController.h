//
//  WelcomeContentViewController.h
//  Gasper Kolenc
//
//  Created by Gasper Kolenc on 07/04/14.
//  Copyright (c) 2014 Gasper Kolenc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeContentViewController : UIViewController

@property (strong, nonatomic) NSString *iconImage;
@property (strong, nonatomic) NSString *descriptionText;

- (void)refreshForOffset:(CGFloat)offset;

@end
