//
//  SnapLoadingViewController.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-06.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapLoadingViewController.h"

#import "SnapApiClient.h"
#import "SnapEvent.h"
#import "SnapEventListViewController.h"

@interface SnapLoadingViewController ()

@end

@implementation SnapLoadingViewController

@synthesize locationController;
@synthesize results;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - View loading & unloading

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.locationController = [[SnapCL alloc] initWithDelegate:self];
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.locationController = nil;
    [super viewWillDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    // if the location controller isn't nil, look for new locations
    if (self.locationController != nil) {
        [self.locationController startUpdatingLocation];
        [loadingSpinner startAnimating];
    }
    [super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    // if the location controller isn't nil, look for new locations
    if (self.locationController != nil) {
        [self.locationController stopUpdatingLocation];
        [loadingSpinner stopAnimating];
    }
    [super viewDidDisappear:animated];
}

#pragma mark - Location

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)locationUpdate:(CLLocation *)location {
	// stop updating the location
    [self.locationController stopUpdatingLocation];
    
    // get a date formatter
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    // setup +/- 48 hours
    NSDate *twoDaysAgo = [now dateByAddingTimeInterval:-48*60*60];
    NSDate *twoDaysFromNow = [now dateByAddingTimeInterval:48*60*60];

    // setup the params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSString stringWithFormat:@"%f", location.coordinate.latitude], @"lat",
        [NSString stringWithFormat:@"%f", location.coordinate.longitude], @"lng",
        @"true", @"enabled",
        [dateFormatter stringFromDate:twoDaysAgo], @"start__gte",
        [dateFormatter stringFromDate:twoDaysFromNow], @"end__lte",
        nil];

    // get the events
    [loadingSpinner startAnimating];
    [[SnapApiClient sharedInstance] getPath:@"event/" parameters:params
        success:^(AFHTTPRequestOperation *operation, id response) {
            // hydrate the response into objects
            self.results = [NSMutableArray array];
            for (id events in [response valueForKeyPath:@"objects"]) {
                SnapEvent *event = [[SnapEvent alloc] initWithDictionary:events];
                [self.results addObject:event];
                DLog(@"event: %@", event.title);
            }

            DLog(@"event count: %d", results.count);
            
            // start the correct screen depending on number of events
            if (self.results.count >= 1) {
                // start the segue for a single event
                [loadingSpinner stopAnimating];
                [self performSegueWithIdentifier:@"eventListSegue" sender:self];
            } else {
                [loadingSpinner stopAnimating];
                [loadingButton setHidden:NO];
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error fetching events!");
            DLog(@"%@", error);
        }
     ];
}

- (void)locationError:(NSError *)error {
	//locationLabel.text = [error description];
    DLog(@"An error occured while getting location.");
    DLog(@"Error: %@", error);
}

#pragma mark Force Reload Events

- (IBAction)searchForEvents:(id)sender {
    // if the location controller isn't nil, look for new locations
    if (self.locationController != nil) {
        [loadingButton setHidden:YES];
        [loadingSpinner startAnimating];
        [self.locationController startUpdatingLocation];
    }
}

#pragma mark Pass data to next scnene

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"eventListSegue"]) {
        // Get destination view
        SnapEventListViewController *vc = [segue destinationViewController];

        // Set the selected button in the new view
        vc.events = self.results;
    }
}


@end
