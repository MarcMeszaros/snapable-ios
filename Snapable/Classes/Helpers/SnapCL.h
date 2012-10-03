//
//  SnapCL.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-06.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol SnapCLControllerDelegate <NSObject>
@required
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
@end

@interface SnapCL : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    id <SnapCLControllerDelegate> _delegate;
    int _updateCount;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) id <SnapCLControllerDelegate> delegate;
@property (nonatomic) int updateCount;

- (id)initWithDelegate:(id)delegate;
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;

// start & stop location updates
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end
