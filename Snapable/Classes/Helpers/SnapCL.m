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

- (id)initWithDelegate:(id)delegate {
    self = [super init];
    if (self != nil) {
        self.updateCount = 0;
        self.delegate = delegate;
        self.locationManager = [[CLLocationManager alloc] init];
        //self.locationManager.delegate = self; // send loc updates to myself
        self.locationManager.purpose = @"Use location to list nearby events.";
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; // desired location accuracy
        //self.locationManager.distanceFilter = 0.01; // only update the location if more than 0.01m has been traveled
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // If it's a relatively recent event, turn off updates to save power
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0)
    {
        DLog(@"how recent (<15): %f", howRecent);
        DLog(@"old: %@", oldLocation);
        DLog(@"new: %@", newLocation);
        self.updateCount++; // increment the updateLocation count
        // only send the event if we have an old & new location
        if (oldLocation != nil && newLocation != nil) {
            double distance = [newLocation distanceFromLocation:oldLocation];
            DLog(@"diff: %f", distance);
            
            // make sure the distance has stabilized (ie. a variance less than 100m)
            // and we have an update count of 2+ (ie. should be stable by 2nd update)
            if(distance <= 100.0 && self.updateCount >= 2) {
                [self.delegate locationUpdate:newLocation];
                self.updateCount = 0;
            }
        }
    } else {
        // else skip the event and process the next one.
        DLog(@"how recent (>15): %f", howRecent);
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
