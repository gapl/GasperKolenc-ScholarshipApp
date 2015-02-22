//
//  TileViewController.m
//  Gasper Kolenc
//
//  Created by Gasper Kolenc on 06/04/14.
//  Copyright (c) 2014 Gasper Kolenc. All rights reserved.
//

#import "TileViewController.h"

@interface TileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *overlayImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionHeightConstraint;
@property (strong, nonatomic) CALayer *maskLayer;

@end

@implementation TileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add blur to overlay view
    UIToolbar *overlayToolbar = [[UIToolbar alloc] initWithFrame:self.headerView.bounds];
    overlayToolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.headerView insertSubview:overlayToolbar atIndex:0];
    
    // Round profile image view
    _profileImage.layer.masksToBounds = YES;
    _profileImage.layer.cornerRadius = _profileImage.bounds.size.width / 2.f;
    
    // Setup header view content
    _overlayImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", (int)_page - 1]];
    _backgroundImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", (int)_page]];
    _titleLabel.text = [_tileDict objectForKey:@"Title"];
    _dateLabel.text = [_tileDict objectForKey:@"Date"];
    NSString *caption = [_tileDict objectForKey:@"Caption"];
    _captionLabel.text = caption;
    
    // Calculate caption label height
    CGFloat labelWidth = [UIScreen mainScreen].bounds.size.width - 24.0;
    CGSize constrainedSize = CGSizeMake(labelWidth - 2 * kArrowLeftOffset, CGFLOAT_MAX);
    CGRect boundingRect = [caption boundingRectWithSize:constrainedSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName : _captionLabel.font} context:nil];
    boundingRect.size.height += 21.0; // Add upper and bottom padding
    CGFloat heightDifference = boundingRect.size.height - _captionHeightConstraint.constant;
    _captionHeightConstraint.constant = boundingRect.size.height;
    _headerHeightConstraint.constant += heightDifference;
    
    // Add a mask layer overall
    _maskLayer = [CALayer layer];
    _maskLayer.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f].CGColor;
    _maskLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:_maskLayer];
    
}

- (void)setMaskLayerOpacity:(CGFloat)opacity
{
    _maskLayer.backgroundColor = [UIColor colorWithWhite:0.0f alpha:opacity].CGColor;
}

- (void)setOverlayImageOffset:(CGFloat)offset
{
    // Showing previous image as overlay with offset so that transparent toolbar blur shows correct blurred image
    CGRect frame = _overlayImage.frame;
    frame.origin.y = offset;
    _overlayImage.frame = frame;
}

@end
