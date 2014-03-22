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

@implementation SnapEventListViewController

static NSString *cellIdentifier = @"eventListCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // add iOS pull to refresh
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.locationController = [[SnapCL alloc] initWithDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // if the location controller isn't nil, look for new locations
    if (self.locationController != nil && self.events.count < 1) {
        [self.locationController startUpdatingLocation];
        [self startLoading];
    }
    [Analytics sendScreenName:@"EventList"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.locationController = nil;
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // if the location controller isn't nil, look for new locations
    if (self.locationController != nil) {
        [self.locationController stopUpdatingLocation];
    }
    [super viewDidDisappear:animated];
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
    startDate = [startDate dateByAddingTimeInterval:(event.tz_offset * 60)]; // add the timezone offset
    //NSDate *endDate = [dateFormat dateFromString:event.end];
    
    // Configure the cell...
    cell.uiEventTitle.text = event.title;
    NSDateFormatter *eventDateFormat = [[NSDateFormatter alloc] init];
    [eventDateFormat setDateFormat:@"EEE MMMM d, h:mm a"];
    
    cell.uiEventDate.text = [eventDateFormat stringFromDate:startDate];
    //cell.uiEventDate.text = [startDate descriptionWithLocale:[NSLocale currentLocale]];

    // set the image to be auto loaded
    NSString *size = @"200x200";
    NSString *photoAbsolutePath = [NSString stringWithFormat:@"%@%@?size=%@", [SnapAPIBaseURL substringToIndex:(SnapAPIBaseURL.length - 1)], event.resource_uri, size];
    [cell.uiPhoto setImageWithSignedURL:[NSURL URLWithString:photoAbsolutePath] placeholderImage:[UIImage imageNamed:@"photoDefault.jpg"]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the event selected
    self.lastSelectedEvent = [self.events objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    
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
        if ((self.lastSelectedEvent.public == false && [self.lastSelectedEvent.pin compare:pin] == NSOrderedSame) || self.lastSelectedEvent.public == true) {
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
    [Analytics sendEventWithCategory:AnalyticsCategoryUIAction action:AnalyticsActionButtonPress label:@"snapable_website" value:nil];
}

#pragma mark - Search
// when the search button is clicked
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    DLog(@"%@", searchBar.text);
    [self searchForEventsWithQuery:searchBar.text];
}

- (void)searchForEventsWithQuery:(NSString *)query
{
    // start the refresh
    [self startLoading];

    // setup the params
    NSDictionary *params = @{
        @"q": query,
        @"enabled": @"true",
        @"order_by": @"end"
    };

    // get the events
    [[SnapApiClient sharedInstance] getPath:@"event/search/" parameters:params
        success:^(AFHTTPRequestOperation *operation, id response) {
            // hydrate the response into objects
            NSMutableArray *results = [NSMutableArray array];
            for (id apiEvent in [response valueForKeyPath:@"objects"]) {
                SnapEvent *event = [[SnapEvent alloc] initWithDictionary:apiEvent];
                [results addObject:event];
            }
            
            // start the correct screen depending on number of events
            self.events = results;
            [self.tableView reloadData];
            [self.uiSearchBar resignFirstResponder];
            
            // hide the no event message if there is at least one event
            if (self.events.count > 0) {
                self.uiNoEventViewGroup.hidden = YES;
            } else {
                self.uiNoEventViewGroup.hidden = NO;
            }

            // end the refresh
            [self stopLoading];
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ALog(@"Error fetching events!");
            DLog(@"%@", error);

            // end the refresh
            [self stopLoading];
        }
     ];
}

- (void)refresh:(UIRefreshControl *)sender
{
    if (self.uiSearchBar.text.length > 0) {
        [self searchForEventsWithQuery:self.uiSearchBar.text];
    } else if (self.locationController != nil) {
        [self.locationController startUpdatingLocation];
    } else {
        [self stopLoading];
    }
}

#pragma mark - Loading
- (void)startLoading
{
    [_tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    [_refreshControl beginRefreshing];
    
    // hide the no event message if there is at least one event
    self.uiNoEventViewGroup.hidden = YES;
}

- (void)stopLoading
{
    [_refreshControl endRefreshing];
    [_tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    // hide the no event message if there is at least one event
    if (self.events.count <= 0) {
        self.uiNoEventViewGroup.hidden = NO;
    }
}

#pragma mark - Location
- (void)locationUpdate:(CLLocation *)location {
	// stop updating the location
    [self.locationController stopUpdatingLocation];
    
    // setup the params
    NSDictionary *params = @{
         @"lat": [NSString stringWithFormat:@"%f", location.coordinate.latitude],
         @"lng": [NSString stringWithFormat:@"%f", location.coordinate.longitude],
         @"enabled": @"true"
     };
    
    // get the events
    [[SnapApiClient sharedInstance] getPath:@"event/" parameters:params
            success:^(AFHTTPRequestOperation *operation, id response) {
                // hydrate the response into objects
                NSMutableArray *results = [NSMutableArray array];
                for (id object in [response valueForKeyPath:@"objects"]) {
                    SnapEvent *event = [[SnapEvent alloc] initWithDictionary:object];
                    [results addObject:event];
                }
                self.events = results;
                [_tableView reloadData];
                [self stopLoading];
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DLog(@"Error fetching events!");
                DLog(@"%@", error);
                [self stopLoading];
            }
     ];
}

- (void)locationError:(NSError *)error {
	DLog(@"An error occured while getting location.");
    DLog(@"Error: %@", error);
}

@end
