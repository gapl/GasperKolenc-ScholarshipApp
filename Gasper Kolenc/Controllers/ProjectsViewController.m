//
//  ProjectsViewController.m
//  Gasper Kolenc
//
//  Created by Gasper Kolenc on 07/04/14.
//  Copyright (c) 2014 Gasper Kolenc. All rights reserved.
//

#define kCellAnimationLength            0.6
#define kCellAnimationCascadeDelay      0.04

#import "ProjectsViewController.h"
#import "AppDetailViewController.h"
#import "AppCell.h"

@interface ProjectsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *appsButton;
@property (weak, nonatomic) IBOutlet UIButton *skillsButton;

@property (strong, nonatomic) NSArray *appsArray;
@property (strong, nonatomic) NSArray *skillsArray;
@property (weak, nonatomic) NSArray *currentDataSource;

@property BOOL cascade;
@property BOOL firstTime;

@end

@implementation ProjectsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _cascade = YES;
    _firstTime = YES;
    
    _appsArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Apps" ofType:@"plist"]];
    _skillsArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Skills" ofType:@"plist"]];
    _currentDataSource = _appsArray;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _currentDataSource.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Detect end of loading to stop cascading
    if(indexPath.row == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        _cascade = NO;
        _firstTime = NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [UIScreen mainScreen].bounds.size.height > 568.0 ? 120.0 : _headerView.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *AppCellIdentifier = @"AppCell";
    AppCell *cell = [tableView dequeueReusableCellWithIdentifier:AppCellIdentifier forIndexPath:indexPath];
    NSDictionary *cellData = [_currentDataSource objectAtIndex:indexPath.row];
    
    // Setup cell appearance
    cell.titleLabel.text = [cellData objectForKey:@"Title"];
    cell.iconImageView.image = [UIImage imageNamed:[cellData objectForKey:@"Icon"]];
    if (_currentDataSource == _skillsArray) {
        cell.disclosureIndicator.hidden = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.disclosureIndicator.hidden = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    // Cascade cells animation
    __block CGRect frame = cell.contentView.frame;
    if (_firstTime || _currentDataSource == _skillsArray)
        frame.origin.x = cell.contentView.frame.size.width;
    else
        frame.origin.x = -cell.contentView.frame.size.width;
    
    cell.contentView.frame = frame;
    frame.origin.x = 0;
    
    if (_cascade) {
        [UIView animateWithDuration:kCellAnimationLength / 2 delay:kCellAnimationCascadeDelay * indexPath.row options:UIViewAnimationOptionCurveEaseOut animations:^{
            cell.contentView.frame = frame;
        } completion:nil];
    }
    
    return cell;
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return _currentDataSource == _appsArray;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSDictionary *cellData = [_currentDataSource objectAtIndex:[_tableView indexPathForSelectedRow].row];
    AppDetailViewController *destinationController = [segue destinationViewController];
    destinationController.appDict = cellData;
}

#pragma mark - Helper methods

- (void)cascadeAndReloadRows
{
    // Begin the cascade animation
    _cascade = YES;
    NSInteger count = 0;
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        __block CGRect frame = cell.contentView.frame;
        
        if (_currentDataSource == _skillsArray)
            frame.origin.x = -cell.contentView.frame.size.width;
        else
            frame.origin.x = cell.contentView.frame.size.width;
        
        [UIView animateWithDuration:kCellAnimationLength / 2 delay:kCellAnimationCascadeDelay * count options:UIViewAnimationOptionCurveEaseIn animations:^{
            cell.contentView.frame = frame;
        } completion:^(BOOL finished){
            frame.origin.x = cell.contentView.frame.size.width;
            cell.contentView.frame = frame;
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        
        count += 1;
    }
}

- (void)setSelectedButton:(UIButton *)button
{
    _appsButton.selected = (_appsButton == button) ? YES : NO;
    _skillsButton.selected = (_skillsButton == button) ? YES : NO;
}

#pragma mark - User actions

- (IBAction)switchToApps:(id)sender
{
    if (_cascade || _currentDataSource == _appsArray) return;
    [self setSelectedButton:sender];
    _currentDataSource = _appsArray;
    [self cascadeAndReloadRows];
}

- (IBAction)switchToSkills:(id)sender
{
    if (_cascade || _currentDataSource == _skillsArray) return;
    [self setSelectedButton:sender];
    _currentDataSource = _skillsArray;
    [self cascadeAndReloadRows];
}

@end
