//
//  SnapLoadingViewController.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-06.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapLoadingViewController.h"

@interface SnapLoadingViewController ()

@end

@implementation SnapLoadingViewController


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
    locationController = [[SnapCL alloc] init];
	locationController.delegate = self;
	[locationController.locationManager startUpdatingLocation];
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

#pragma mark - Location

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)locationUpdate:(CLLocation *)location {
	//locationLabel.text = [location description];
    loadingLabel.text = [NSString stringWithFormat:@"%f, %f", location.coordinate.latitude, location.coordinate.longitude];
    NSLog(@"loc: %@", [location description]);
}

- (void)locationError:(NSError *)error {
	//locationLabel.text = [error description];
    NSLog(@"An error occured while getting location.");
    NSLog(@"Error: %@", error);
}

@end
