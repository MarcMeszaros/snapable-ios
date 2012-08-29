//
//  SnapEventListViewController.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-12.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapEventListViewController.h"
#import "SnapEventListCell.h"

#import "SnapEventPhotoListViewController.h"
#import "SnapEventListAuthViewController.h"

#import "ISO8601DateFormatter.h"
#import "Toast+UIView.h"

@interface SnapEventListViewController ()

@end

@implementation SnapEventListViewController

static NSString *cellIdentifier = @"eventListCell";

@synthesize events;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1; // only 1 section (ie. all events)
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SnapEventListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // get the event
    SnapEvent *event = [self.events objectAtIndex:indexPath.row];

    if (cell == nil) {
        cell = [[SnapEventListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Convert string to date object
    ISO8601DateFormatter *dateFormat = [[ISO8601DateFormatter alloc] init];
    NSDate *startDate = [dateFormat dateFromString:event.start];
    //NSDate *endDate = [dateFormat dateFromString:event.end];
    
    // Configure the cell...
    cell.uiEventTitle.text = event.title;
    NSDateFormatter *eventDateFormat = [[NSDateFormatter alloc] init];
    [eventDateFormat setDateFormat:@"EEE MMMM d, h:mm a"];
    
    cell.uiEventDate.text = [eventDateFormat stringFromDate:startDate];
    //cell.uiEventDate.text = [startDate descriptionWithLocale:[NSLocale currentLocale]];
    
    // set the image string
    NSString *photoAbsolutePath;
    
    // if it's the original screen resolution
    if([[UIScreen mainScreen] scale] == 1.0f){
        photoAbsolutePath = [NSString stringWithFormat:@"%@%@?size=100x100", [SnapAPIBaseURL substringToIndex:(SnapAPIBaseURL.length - 1)], event.resource_uri];
    }
    // else retina
    else {
        photoAbsolutePath = [NSString stringWithFormat:@"%@%@?size=200x200", [SnapAPIBaseURL substringToIndex:(SnapAPIBaseURL.length - 1)], event.resource_uri];
    }

    // set the image to be auto loaded
    [cell.uiPhoto setImageWithURL:[NSURL URLWithString:photoAbsolutePath] placeholderImage:[UIImage imageNamed:@"photoDefault.jpg"]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the event selected
    SnapEvent *event = [self.events objectAtIndex:indexPath.row];
    NSInteger privacyNumber = [SnapApiClient getIdFromResourceUri:event.type];
    
    DLog(@"privacy number: %d", privacyNumber);
    
    // if the privacy number is less than 6 prompt for the pin
    if (privacyNumber < 6) {
        [self performSegueWithIdentifier:@"eventListAuthSegue" sender:self];
    }
    else {
        // Navigation logic may go here. Create and push another view controller.
        [self performSegueWithIdentifier:@"eventListPhotoSegue" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"eventListPhotoSegue"]) {
        // Get destination view
        SnapEventPhotoListViewController *vc = [segue destinationViewController];
        
        // Set the selected button in the new view
        vc.event = [self.events objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    }
    else if ([[segue identifier] isEqualToString:@"eventListAuthSegue"]) {
        // Get destination view
        SnapEventListAuthViewController *vc = [segue destinationViewController];
        vc.parentVC = self;
    
        // Set the selected button in the new view
        vc.event = [self.events objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    }
}

// handle alert views
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    DLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
    UITextField *pin = (UITextField *)[alertView viewWithTag:-1];
    DLog(@"PIN: %@",pin.text);
    
    // if the values match, go to the event
    if ([[[alertView textFieldAtIndex:0] text] compare:pin.text] == NSOrderedSame) {
        [self performSegueWithIdentifier:@"eventListPhotoSegue" sender:self];
    }
    // the pin is invalid show a toast notification
    else {
        [self.view makeToast:@"The PIN entered was invalid." duration:3.0 position:@"center"];
    }
}

#pragma mark - Row modifications
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // this shouldn't be hard
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    return cell.frame.size.height;
}

@end
