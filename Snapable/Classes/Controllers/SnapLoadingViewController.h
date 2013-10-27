//
//  SnapLoadingViewController.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-06.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnapCL.h"

@interface SnapLoadingViewController : GAITrackedViewController <SnapCLControllerDelegate> {
    
}

@property (nonatomic, strong) SnapCL *locationController;
@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) IBOutlet UILabel *loadingLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingSpinner;

- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;

@end
