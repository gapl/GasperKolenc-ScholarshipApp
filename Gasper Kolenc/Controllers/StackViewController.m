//
//  StackViewController.m
//  Gasper Kolenc
//
//  Created by Gasper Kolenc on 06/04/14.
//  Copyright (c) 2014 Gasper Kolenc. All rights reserved.
//

#import "StackViewController.h"
#import "TileViewController.h"

@interface StackViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSArray *tilesContentArray;
@property (strong, nonatomic) NSMutableArray *tileViewControllers;
@property (strong, nonatomic) UIPanGestureRecognizer *panRecognizer;
@property NSUInteger numberOfPages;
@property NSUInteger currentPage;
@property CGFloat previousPosition;

@end

@implementation StackViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Timeline" ofType:@"plist"];
        self.tilesContentArray = [NSArray arrayWithContentsOfFile:plistPath];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load tile controllers lazily
    _numberOfPages = _tilesContentArray.count;
    _currentPage = 0;
    NSMutableArray *controllers = [NSMutableArray array];
    for (NSUInteger i = 0; i < _numberOfPages; i++) {
		[controllers addObject:[NSNull null]];
    }
    _tileViewControllers = controllers;
    
    // Load first controllers
    [self loadTileViewControllerForPage:0 above:NO];
    [self loadTileViewControllerForPage:1 above:NO];
    [self loadTileViewControllerForPage:2 above:NO];
    [[_tileViewControllers objectAtIndex:_currentPage] setMaskLayerOpacity:0.0];
    
    // Setup tap gesture recognizer
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveToNext:)];
    [tapRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapRecognizer];
    
    // Setup pan gesture recognizer
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveTiles:)];
    [_panRecognizer setMinimumNumberOfTouches:1];
    [_panRecognizer setMaximumNumberOfTouches:1];
    [_panRecognizer setDelegate:self];
    [self.view addGestureRecognizer:_panRecognizer];
}

#pragma mark - Helper methods

- (void)loadTileViewControllerForPage:(NSUInteger)page above:(BOOL)above
{
    if (page >= _numberOfPages)
        return;
    
    // Replace the placeholder if necessary
    TileViewController *controller = [_tileViewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TileViewController"];
        controller.tileDict = [_tilesContentArray objectAtIndex:page];
        controller.page = page + 1;
        [_tileViewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // Add the controller's view as subview
    if (controller.view.superview == nil) {
        [self addChildViewController:controller];
        if (above) {
            CGRect frame = controller.view.frame;
            frame.origin.y = - self.view.frame.size.height + self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
            controller.view.frame = frame;
            [self.view addSubview:controller.view];
        } else {
            [self.view insertSubview:controller.view atIndex:0];
            [controller setMaskLayerOpacity:kMaxMaskAlpha];
        }
    }
}

- (void)unloadTileViewControllerForPage:(NSUInteger)page
{
    if (page >= _numberOfPages)
        return;
    
    // Replace controller with a placeholder
    UIViewController *controller = [_tileViewControllers objectAtIndex:page];
    if ((NSNull *)controller != [NSNull null]) {
        [_tileViewControllers replaceObjectAtIndex:page withObject:[NSNull null]];
        [controller.view removeFromSuperview];
        controller = nil;
    }
}

- (void)hideAdjacentControllers:(BOOL)hide
{
    if (_currentPage != 0) {
        // Hide previous controller
        TileViewController *controller = [_tileViewControllers objectAtIndex:_currentPage - 1];
        controller.view.hidden = hide;
    }
    
    if (_currentPage != _numberOfPages - 1) {
        // Hide next controller
        TileViewController *controller = [_tileViewControllers objectAtIndex:_currentPage + 1];
        controller.view.hidden = hide;
    }
}

#pragma mark - Gesure recognizer methods

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)recognizer
{
    if ([recognizer isKindOfClass:[UITapGestureRecognizer class]])
        return YES;
    
    CGPoint velocity = [recognizer velocityInView:recognizer.view];
    if (_currentPage == _numberOfPages - 1 && velocity.y <= 0)
        return NO;
    if (_currentPage == 0 && velocity.y >= 0)
        return NO;
    return ABS(velocity.x) < ABS(velocity.y);
}

- (void)moveToNext:(UIPanGestureRecognizer *)recognizer
{
    if (_currentPage == _numberOfPages - 1 || !_panRecognizer.view) return;
    
    [self.view removeGestureRecognizer:_panRecognizer];
    [self hideAdjacentControllers:NO];
    TileViewController *currentController = [_tileViewControllers objectAtIndex:_currentPage];
    TileViewController *bottomController = (_currentPage + 1 < _tileViewControllers.count) ? [_tileViewControllers objectAtIndex:_currentPage + 1] : nil;
    CGFloat maxOffset = - currentController.view.frame.size.height + self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    CGRect finalframe = currentController.view.frame;
    finalframe.origin.y = maxOffset;
    
    CGFloat alpha = -((finalframe.origin.y / (maxOffset * 2 / 3)) - 1) * kMaxMaskAlpha;
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        currentController.view.frame = finalframe;
        [bottomController setMaskLayerOpacity:alpha];
        [bottomController setOverlayImageOffset:finalframe.origin.y];
    } completion:^(BOOL finished){
        _currentPage += 1;
        [self loadTileViewControllerForPage:_currentPage+1 above:NO];
        [self unloadTileViewControllerForPage:_currentPage-2];
        [self hideAdjacentControllers:YES];
        [self.view addGestureRecognizer:_panRecognizer];
    }];
}

- (void)moveTiles:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    TileViewController *currentController = [_tileViewControllers objectAtIndex:_currentPage];
    TileViewController *bottomController = (_currentPage + 1 < _tileViewControllers.count) ? [_tileViewControllers objectAtIndex:_currentPage + 1] : nil;
    
    BOOL goToPrev = NO;
    if (translatedPoint.y > 0) {
        bottomController = [_tileViewControllers objectAtIndex:_currentPage];
        goToPrev = YES;
    }
    CGFloat maxOffset = - currentController.view.frame.size.height + self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    
    // If user starts dragging quickly in the other direction - move previous controller to correct position
    if (_previousPosition < 0 && translatedPoint.y > 0) {
        CGRect newFrame = bottomController.view.frame;
        newFrame.origin.y = 0;
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            bottomController.view.frame = newFrame;
        } completion:nil];
    } else if (_previousPosition > 0 && translatedPoint.y < 0) {
        TileViewController *previousController = (_currentPage != 0) ? [_tileViewControllers objectAtIndex:_currentPage - 1] : nil;
        CGRect newFrame = previousController.view.frame;
        newFrame.origin.y = maxOffset;
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            previousController.view.frame = newFrame;
            [currentController setOverlayImageOffset:newFrame.origin.y];
        } completion:nil];
    }
    
    // Check for end conditions
    if (translatedPoint.y > 0) {
        if (_currentPage == 0) return;
        currentController = [_tileViewControllers objectAtIndex:_currentPage - 1];
    } else {
        if (_currentPage == _numberOfPages - 1) return;
    }
    
    // If ended, transition to next/previous
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self hideAdjacentControllers:NO];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        CGPoint velocity = [recognizer velocityInView:recognizer.view];
        CGRect finalframe = currentController.view.frame;
        
        // Going one tile back succesfully
        if (goToPrev && (velocity.y > self.view.frame.size.height || translatedPoint.y > -maxOffset / 2))
            finalframe.origin.y = 0;
        
        // Going one tile back unsuccesfully
        else if (goToPrev)
            finalframe.origin.y = maxOffset;
        
        // Going one tile forward succesfully
        else if (velocity.y < -self.view.frame.size.height || translatedPoint.y < maxOffset / 2)
            finalframe.origin.y = maxOffset;
        
        // Going one tile forward unsuccesfully
        else
            finalframe.origin.y = 0;
        
        CGFloat alpha = -((finalframe.origin.y / (maxOffset * 2 / 3)) - 1) * kMaxMaskAlpha;
        // Animate changes
        [self.view removeGestureRecognizer:_panRecognizer];
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            currentController.view.frame = finalframe;
            [bottomController setMaskLayerOpacity:alpha];
            [bottomController setOverlayImageOffset:finalframe.origin.y];
        } completion:^(BOOL finished){
            if (goToPrev && finalframe.origin.y == 0) {
                _currentPage -= 1;
                [self loadTileViewControllerForPage:_currentPage-1 above:YES];
                [self unloadTileViewControllerForPage:_currentPage+2];
            } else if (!goToPrev && finalframe.origin.y != 0) {
                _currentPage += 1;
                [self loadTileViewControllerForPage:_currentPage+1 above:NO];
                [self unloadTileViewControllerForPage:_currentPage-2];
            }
            [self hideAdjacentControllers:YES];
            [self.view addGestureRecognizer:_panRecognizer];
        }];
        return;
    }
    
    // Set new frame of current controller
    CGRect newFrame = currentController.view.frame;
    if (translatedPoint.y < 0) {
        newFrame.origin.y = translatedPoint.y;
    } else if (translatedPoint.y > 0) {
        newFrame.origin.y = translatedPoint.y + maxOffset;
    }
    currentController.view.frame = newFrame;
    _previousPosition = translatedPoint.y;
    [currentController setOverlayImageOffset:-newFrame.size.height];
    
    // Set alpha of bottom controller
    CGFloat alpha = -((newFrame.origin.y / (maxOffset * 2 / 3)) - 1) * kMaxMaskAlpha;
    [bottomController setMaskLayerOpacity:alpha];
    [bottomController setOverlayImageOffset:newFrame.origin.y];
}

@end
