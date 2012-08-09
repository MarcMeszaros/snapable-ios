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

@interface SnapLoadingViewController ()

@end

@implementation SnapLoadingViewController

@synthesize locationController;

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
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    // if the location controller isn't nil, look for new locations
    if (self.locationController != nil) {
        [self.locationController.locationManager startUpdatingLocation];
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    // if the location controller isn't nil, look for new locations
    if (self.locationController != nil) {
        [self.locationController.locationManager stopUpdatingLocation];
    }
}

#pragma mark - Location

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)locationUpdate:(CLLocation *)location {
	//locationLabel.text = [location description];
    NSLog(@"loc: %@", [location description]);
    [self.locationController.locationManager stopUpdatingLocation];
    
    // get the events
    NSString *request_string = [NSString stringWithFormat:@"event/?lat=%f&lng=%f", location.coordinate.latitude, location.coordinate.longitude];
    [[SnapApiClient sharedInstance] getPath:request_string parameters:nil
        success:^(AFHTTPRequestOperation *operation, id response) {
            // hydrate the response into objects
            NSMutableArray* results = [NSMutableArray array];
            for (id events in [response valueForKeyPath:@"objects"]) {
                SnapEvent *event = [[SnapEvent alloc] initWithDictionary:events];
                [results addObject:event];
                NSLog(@"event: %@", event.title);
            }
            
            // start the correct screen depending on number of events
            if (results.count == 1) {
                // start the segue for a single event
                [self performSegueWithIdentifier:@"eventListSegue" sender:self];
            } else if (results.count > 1) {
                // start the segue for multiple events
                [self performSegueWithIdentifier:@"multiEventListSegue" sender:self];
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

@end
