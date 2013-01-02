//
//  SnapEventListViewController.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-12.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapAppDelegate.h"
#import "SnapEventListViewController.h"
#import "SnapEventListCell.h"
#import "FMDatabase.h"

#import "SnapEventPhotoListViewController.h"
#import "SnapEventListAuthViewController.h"

#import "ISO8601DateFormatter.h"
#import "Toast+UIView.h"

@interface SnapEventListViewController ()

@end

@implementation SnapEventListViewController

static NSString *cellIdentifier = @"eventListCell";

@synthesize events;
@synthesize lastSelectedEvent;
@synthesize uiNoEventViewGroup;
@synthesize uiSearchBar;

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

    // hide the no event message if there is at least one event
    if (self.events.count > 0) {
        self.uiNoEventViewGroup.hidden = YES;
        CGRect rect = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
        [self.uiNoEventViewGroup setFrame:rect];
    }

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[GANTracker sharedTracker] trackPageview:@"/eventList" withError:nil];
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
    self.lastSelectedEvent = [self.events objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    NSInteger privacyNumber = [SnapApiClient getIdAsIntegerFromResourceUri:self.lastSelectedEvent.type];
    
    DLog(@"privacy number: %d", privacyNumber);
    
    // open local storage
    SnapAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.database open];
    
    // create the query to get the data
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM event_credentials WHERE id = %d", [SnapApiClient getIdAsIntegerFromResourceUri:self.lastSelectedEvent.resource_uri]];
    FMResultSet *results = [delegate.database executeQuery:query];

    // we have auth credentials check if they are correct
    if([results next]) {
        // parse the sql data results
        NSString *pin = [results stringForColumn:@"pin"];
        
        // pins match or no pin required
        if ((privacyNumber < 6 && [self.lastSelectedEvent.pin compare:pin] == NSOrderedSame) || privacyNumber == 6) {
            [self performSegueWithIdentifier:@"eventListPhotoSegue" sender:self];
        }
        // pins don't match
        else {
            [self performSegueWithIdentifier:@"eventListAuthSegue" sender:self];
        }
    }
    // no stored event credentials, go to auth screen
    else {
        [self performSegueWithIdentifier:@"eventListAuthSegue" sender:self];
    }
    
    // close the database
    [delegate.database close];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"eventListPhotoSegue"]) {
        // Get destination view
        SnapEventPhotoListViewController *vc = [segue destinationViewController];
        
        // Set the selected button in the new view
        vc.event = self.lastSelectedEvent;
    }
    else if ([[segue identifier] isEqualToString:@"eventListAuthSegue"]) {
        // Get destination view
        SnapEventListAuthViewController *vc = [segue destinationViewController];
        vc.parentVC = self;
        
        // Set the selected button in the new view
        vc.event = self.lastSelectedEvent;
    }
}

#pragma mark - Row modifications
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // this shouldn't be hard
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    return cell.frame.size.height;
}

#pragma mark - UIAction
- (IBAction)goToSnapable:(id)sender {
    NSString* launchUrl = @"http://snapable.com/";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
}

#pragma mark - Search
// when the search button is clicked
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    DLog(searchBar.text);
    [self searchForEventsWithQuery:searchBar.text];
}

- (void)searchForEventsWithQuery:(NSString *)query
{
    // setup the params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
        query, @"q",
        @"true", @"enabled",
        nil];
    
    // get the events
    [[SnapApiClient sharedInstance] getPath:@"event/search/" parameters:params
        success:^(AFHTTPRequestOperation *operation, id response) {
            // hydrate the response into objects
            NSMutableArray *results = [NSMutableArray array];
            for (id apiEvent in [response valueForKeyPath:@"objects"]) {
                SnapEvent *event = [[SnapEvent alloc] initWithDictionary:apiEvent];
                [results addObject:event];
                DLog(@"event: %@", event.title);
            }
            
            // start the correct screen depending on number of events
            self.events = results;
            [self.tableView reloadData];
            [self.uiSearchBar resignFirstResponder];
            
            // hide the no event message if there is at least one event
            if (self.events.count > 0) {
                self.uiNoEventViewGroup.hidden = YES;
                CGRect rect = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
                [self.uiNoEventViewGroup setFrame:rect];
            } else {
                self.uiNoEventViewGroup.hidden = NO;
                CGRect rect = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
                [self.uiNoEventViewGroup setFrame:rect];
                
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error fetching events!");
            DLog(@"%@", error);
        }
     ];
}

@end
