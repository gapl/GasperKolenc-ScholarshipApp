//
//  SideMenuViewController.m
//  Gasper Kolenc
//
//  Created by Gasper Kolenc on 06/04/14.
//  Copyright (c) 2014 Gasper Kolenc. All rights reserved.
//

#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "SideMenuCell.h"
#import "RoundedButton.h"

@interface SideMenuViewController ()

@property (strong, nonatomic) NSArray *menuArray;

@end

@implementation SideMenuViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"SideMenu" ofType:@"plist"];
        self.menuArray = [NSArray arrayWithContentsOfFile:plistPath];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set top content inset
    UIEdgeInsets contentInset = self.tableView.contentInset;
    contentInset.top = 29;
    self.tableView.contentInset = contentInset;
    
    // Add return buttom in bottom left corner
    CGSize buttonSize = CGSizeMake(60, 60);
    RoundedButton *returnButton = [RoundedButton buttonWithType:UIButtonTypeCustom];
    returnButton.frame = CGRectMake(20, self.view.frame.size.height - contentInset.top - 20 - buttonSize.height, buttonSize.width, buttonSize.height);
    [returnButton addTarget:self action:@selector(returnToWelcomeView:) forControlEvents:UIControlEventTouchUpInside];
    [returnButton setImage:[UIImage imageNamed:@"Return"] forState:UIControlStateNormal];
    [returnButton setImage:[UIImage imageNamed:@"ReturnHighlighted"] forState:UIControlStateHighlighted];
    returnButton.normalColor = [UIColor whiteColor];
    returnButton.selectedColor = kGreenColor;
    [self.view addSubview:returnButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Select first cell
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.menuArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SideMenuCell";
    SideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *cellData = [self.menuArray objectAtIndex:indexPath.section];
    cell.titleLabel.text = [cellData objectForKey:@"Title"];
    cell.iconName = [cellData objectForKey:@"Title"];
    cell.iconImageView.image = [UIImage imageNamed:cell.iconName];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellData = [self.menuArray objectAtIndex:indexPath.section];
    UIViewController *centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:[cellData objectForKey:@"Identifier"]];
    centerViewController.title = [cellData objectForKey:@"Title"];
    
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    navigationController.viewControllers = @[centerViewController];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

#pragma mark - User actions

- (void)returnToWelcomeView:(UIButton *)sender
{
    UIViewController *welcomeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    navigationController.viewControllers = @[welcomeViewController];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

@end
