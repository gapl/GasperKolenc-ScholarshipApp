//
//  MeViewController.m
//  Gasper Kolenc
//
//  Created by Gasper Kolenc on 07/04/14.
//  Copyright (c) 2014 Gasper Kolenc. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "MeViewController.h"
#import "MeDetailCell.h"

@interface MeViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataArray;

@end

@implementation MeViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Me" ofType:@"plist"];
        self.dataArray = [NSArray arrayWithContentsOfFile:plistPath];
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.dataArray objectAtIndex:section] objectForKey:@"Items"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0)
        return 124.0;
    
    NSString *sectionTitle = [[self.dataArray objectAtIndex:indexPath.section] objectForKey:@"Title"];
    if ([sectionTitle isEqualToString:@"Summary"])
        return [UIScreen mainScreen].bounds.size.height > 568.0 ? 186.0 : 200.0;
    
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 22.0;
    if (section == 1)
        return 17.0;
    
    return 40.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section < 2) return nil;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 40.0)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 10.0, 290.0, 30.0)];
    titleLabel.text = [[self.dataArray objectAtIndex:section] objectForKey:@"Title"];
    titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14.0];
    titleLabel.textColor = [UIColor colorWithWhite:0.40 alpha:1.0];
    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellDict = [[[self.dataArray objectAtIndex:indexPath.section] objectForKey:@"Items"] objectAtIndex:indexPath.row];
    NSString *cellIdentifier = [cellDict objectForKey:@"Identifier"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Set layer mask on header cell image view
    if (indexPath.section == 0 && indexPath.row == 0) {
        for (UIView *subview in cell.contentView.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                subview.layer.masksToBounds = YES;
                subview.layer.cornerRadius = subview.bounds.size.width / 2.f;
            }
        }
    }
    
    // Setup content cells
    if ([cellIdentifier isEqualToString:@"MeDetailCell"]) {
        ((MeDetailCell *)cell).titleLabel.text = [cellDict objectForKey:@"Title"];
        
        // Set correct font
        if ([[[self.dataArray objectAtIndex:indexPath.section] objectForKey:@"Title"] isEqualToString:@"Education"]) {
            ((MeDetailCell *)cell).detailLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:13.0];
            NSMutableAttributedString *detail = [[NSMutableAttributedString alloc] initWithString:[cellDict objectForKey:@"Detail"]];
            NSRange range = [[cellDict objectForKey:@"Detail"] rangeOfString:@","];
            [detail addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Italic" size:13.0] range:NSMakeRange(range.location, detail.length - range.location)];
            ((MeDetailCell *)cell).detailLabel.attributedText = detail;
        } else {
            ((MeDetailCell *)cell).detailLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0];
            ((MeDetailCell *)cell).detailLabel.text = [cellDict objectForKey:@"Detail"];
        }
        
        // Show selection on email cells
        NSURL *callURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", [[cellDict objectForKey:@"Detail"] stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        if ([[cellDict objectForKey:@"Title"] isEqualToString:@"Email"] ||
            ([[cellDict objectForKey:@"Title"] isEqualToString:@"Phone"] && [[UIApplication sharedApplication] canOpenURL:callURL]))
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    else if ([cellIdentifier isEqualToString:@"MeEmploymentCell"]) {
        ((MeDetailCell *)cell).titleLabel.text = [NSString stringWithFormat:@"%@\n%@", [cellDict objectForKey:@"Date1"], [cellDict objectForKey:@"Date2"]];
        ((UILabel *)[cell viewWithTag:1]).text = [cellDict objectForKey:@"Company"];
        ((UILabel *)[cell viewWithTag:2]).text = [cellDict objectForKey:@"Position"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:[MeDetailCell class]]) return;
    NSString *title = ((MeDetailCell *)cell).titleLabel.text;
    NSString *detail = ((MeDetailCell *)cell).detailLabel.text;
    
    if ([title isEqualToString:@"Email"]) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
            [composeViewController setMailComposeDelegate:self];
            [composeViewController setToRecipients:@[detail]];
            [composeViewController setSubject:@"About your CV..."];
            [self presentViewController:composeViewController animated:YES completion:nil];
        }
    } else if ([title isEqualToString:@"Phone"]) {
        NSURL *callURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", [detail stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        [[UIApplication sharedApplication] openURL:callURL];
    }
}

#pragma Mail Compose delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
