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
    self.locationController = [[SnapCL alloc] init];
	self.locationController.delegate = self;
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
    NSLog(@"viewWillAppear");
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewWillDisappear");
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
    // if the location controller isn't nil, look for new locations
    if (self.locationController.locationManager != nil) {
        [self.locationController.locationManager startUpdatingLocation];
        [loadingSpinner startAnimating];
    }
    [super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    NSLog(@"viewDidDisappear");
    // if the location controller isn't nil, look for new locations
    if (self.locationController.locationManager != nil) {
        [self.locationController.locationManager stopUpdatingLocation];
        [loadingSpinner stopAnimating];
    }
    [super viewDidDisappear:animated];
}

#pragma mark - Location

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)locationUpdate:(CLLocation *)location {
    NSLog(@"before segue");
    
	// stop updating the location
    [self.locationController.locationManager stopUpdatingLocation];
    
    // get the events
    [loadingSpinner startAnimating];
    NSString *request_string = [NSString stringWithFormat:@"event/?lat=%f&lng=%f&enabled=true", location.coordinate.latitude, location.coordinate.longitude];
    [[SnapApiClient sharedInstance] getPath:request_string parameters:nil
        success:^(AFHTTPRequestOperation *operation, id response) {
            // hydrate the response into objects
            self.results = [NSMutableArray array];
            for (id events in [response valueForKeyPath:@"objects"]) {
                SnapEvent *event = [[SnapEvent alloc] initWithDictionary:events];
                [self.results addObject:event];
                NSLog(@"event: %@", event.title);
            }

            NSLog(@"results count: %d", results.count);
            
            // start the correct screen depending on number of events
            if (self.results.count == 1) {
                // start the segue for a single event
                [loadingSpinner stopAnimating];
                [self performSegueWithIdentifier:@"eventListSegue" sender:self];
            } else if (self.results.count > 1) {
                // start the segue for multiple events
                [loadingSpinner stopAnimating];
                [self performSegueWithIdentifier:@"multiEventListSegue" sender:self];
            } else {
                [loadingSpinner stopAnimating];
                [loadingButton setHidden:NO];
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error fetching events!");
            NSLog(@"%@", error);
        }
     ];
}

- (void)locationError:(NSError *)error {
	//locationLabel.text = [error description];
    NSLog(@"An error occured while getting location.");
    NSLog(@"Error: %@", error);
}

#pragma mark Force Reload Events

- (IBAction)searchForEvents:(id)sender {
    // if the location controller isn't nil, look for new locations
    if (self.locationController != nil) {
        [loadingButton setHidden:YES];
        [loadingSpinner startAnimating];
        [self.locationController.locationManager startUpdatingLocation];
    }
}

#pragma mark Pass data to next scnene

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"eventListSegue"]) {
        NSLog(@"in prepare for segue");
        // Get destination view
        SnapEventListViewController *vc = [segue destinationViewController];

        SnapEvent *ev = [self.results objectAtIndex:0];
        NSLog(@"event title before segue: %@", ev.title);
        
        // Set the selected button in the new view
        vc.event = [self.results objectAtIndex:0];
    }
}


@end
