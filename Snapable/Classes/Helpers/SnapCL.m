//
//  SnapCL.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-06.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapCL.h"

@implementation SnapCL

@synthesize locationManager;
@synthesize delegate = _delegate;
@synthesize updateCount = _updateCount;

- (id)initWithDelegate:(id)delegate {
    self = [super init];
    if (self != nil) {
        self.updateCount = 0;
        self.delegate = delegate;
        self.locationManager = [[CLLocationManager alloc] init];
        //self.locationManager.delegate = self; // send loc updates to myself
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // desired location accuracy
        //self.locationManager.distanceFilter = 0.01; // only update the location if more than 0.01m has been traveled
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // If it's a relatively recent event, turn off updates to save power
    DLog(@"new location: %@", newLocation);
    
    // if the new location less than 100m, use it
    if (newLocation.horizontalAccuracy <= 100.0f) {
        [self.delegate locationUpdate:newLocation];
        self.updateCount = 0;
    } else {
        // give up (ie. should be stable enough by 3rd update, we tried...)
        if(self.updateCount >= 3) {
            [self.delegate locationUpdate:newLocation];
            self.updateCount = 0;
        }
        self.updateCount++; // increment the count
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	[self.delegate locationError:error];
}

#pragma mark - Start/Stop Updating Location
- (void)startUpdatingLocation {
    DLog(@"Start updating GPS location.");
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
    DLog(@"Stop updating GPS location.");
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
}

@end
