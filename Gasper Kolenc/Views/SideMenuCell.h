//
//  SideMenuCell.h
//  Gasper Kolenc
//
//  Created by Gasper Kolenc on 06/04/14.
//  Copyright (c) 2014 Gasper Kolenc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) NSString *iconName;

@end
