//
//  WelcomeViewController.m
//  Gasper Kolenc
//
//  Created by Gasper Kolenc on 07/04/14.
//  Copyright (c) 2014 Gasper Kolenc. All rights reserved.
//

#import "WelcomeViewController.h"
#import "WelcomeContentViewController.h"
#import "MFSideMenu.h"

@interface WelcomeViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *overlayBottomSpacing;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIScrollView *welcomeScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) NSArray *welcomePages;
@property BOOL isUserDragging;

@end

@implementation WelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Instantiate welcoming view controllers
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Welcome" ofType:@"plist"];
    NSArray *pages = [NSArray arrayWithContentsOfFile:plistPath];
    NSMutableArray *welcomeTempArray = [NSMutableArray array];
    for (NSInteger x = 0; x < pages.count; x ++) {
        NSDictionary *page = pages[x];
        WelcomeContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeContentViewController"];
        pageContentViewController.iconImage = [page objectForKey:@"Image"];
        pageContentViewController.descriptionText = [page objectForKey:@"Description"];
        [welcomeTempArray addObject:pageContentViewController];
    }
    self.welcomePages = [NSArray arrayWithArray:welcomeTempArray];
    
    // Add tap gesture recognizer to scroll view
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    singleTapGestureRecognizer.enabled = YES;
    singleTapGestureRecognizer.cancelsTouchesInView = NO;
    [_welcomeScrollView addGestureRecognizer:singleTapGestureRecognizer];
    
    _overlayBottomSpacing.constant -= _overlayView.frame.size.height;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.menuContainerViewController setPanMode:MFSideMenuPanModeNone];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_overlayBottomSpacing.constant == 0) return;
    
    // Animate overlay view
    _overlayBottomSpacing.constant += _overlayView.frame.size.height;
    [UIView animateWithDuration:0.8 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        // Populate welcome scroll view
        _welcomeScrollView.contentSize = CGSizeMake(_welcomeScrollView.frame.size.width * _welcomePages.count, _welcomeScrollView.frame.size.height);
        for (NSInteger x = 0; x < _welcomePages.count; x++) {
            WelcomeContentViewController *contentViewController = _welcomePages[x];
            CGRect frame = _welcomeScrollView.bounds;
            frame.origin.x = _welcomeScrollView.bounds.size.width * x;
            contentViewController.view.frame = frame;
            [_welcomeScrollView addSubview:contentViewController.view];
        }
        
        // Start animating scroll view
        _welcomeScrollView.contentOffset = CGPointMake(-_welcomeScrollView.bounds.size.width, 0);
        _isUserDragging = NO;
        [self startScrollAnimation];
        
        // Animate scroll view visibility
        [UIView animateWithDuration:0.5 animations:^{
            _welcomeScrollView.alpha = 1.0;
            _pageControl.alpha = 1.0;
        }];
    }];
}

#pragma mark - Gesture handling

- (void)singleTap:(UIGestureRecognizer *)recognizer
{
    _isUserDragging = YES;
    if (_pageControl.currentPage == _welcomePages.count - 1) return;
    
    CGPoint contentOffset = CGPointMake(_welcomeScrollView.frame.size.width * (_pageControl.currentPage + 1), 0);
    [UIView animateWithDuration:0.4 animations:^{
        _welcomeScrollView.contentOffset = contentOffset;
    } completion:^(BOOL finished){
        _isUserDragging = NO;
        [self startScrollAnimation];
    }];
}

#pragma mark - Animation methods

- (void)startScrollAnimation
{
    // End animation if user scrolled
    if (_isUserDragging)
        return;
    
    // End animation at the end
    if (_welcomeScrollView.contentOffset.x >= _welcomeScrollView.bounds.size.width * (_welcomePages.count - 1))
        return;
    
    CGPoint newOffset = _welcomeScrollView.contentOffset;
    newOffset.x += 0.5;
    _welcomeScrollView.contentOffset = newOffset;
    [self performSelector:@selector(startScrollAnimation) withObject:nil afterDelay:[self delayForOffsetX:newOffset.x]];
}

// Delay offset of content view controllers with a gaussian normal function
- (NSTimeInterval)delayForOffsetX:(CGFloat)x
{
    // Gaussian function variables
    CGFloat deviation = 1.0;
    CGFloat speedup = 12.0;
    CGFloat minimum = 0.0005;
    
    // Transform x
    x = ((NSInteger)x % (NSInteger)_welcomeScrollView.frame.size.width);
    if (x > _welcomeScrollView.frame.size.width / 2) x -= _welcomeScrollView.frame.size.width;
    x = (x / _welcomeScrollView.frame.size.width) * 20;
    
    CGFloat exp = - (0.5 * powf(x , 2.0)) / powf(deviation , 2.0);
    CGFloat result = (((0.398942 * powf(2.71828 , exp)) / deviation) / speedup) + minimum;
    
    return result;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Reset side menu selection
    [self.menuContainerViewController.leftMenuViewController viewWillAppear:NO];
}

#pragma mark - Scroll view delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Setup current page
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControl.currentPage = page;
    
    // Update view controllers
    for (NSInteger x = 0; x < _welcomePages.count; x++) {
        WelcomeContentViewController *contentViewController = _welcomePages[x];
        [contentViewController refreshForOffset:scrollView.contentOffset.x - scrollView.bounds.size.width * x];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isUserDragging = YES;
}

@end
