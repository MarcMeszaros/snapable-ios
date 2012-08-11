//
//  SnapLoadingViewController.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-06.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnapCL.h"

@interface SnapLoadingViewController : UIViewController <SnapCLControllerDelegate> {
    SnapCL *locationController;
    IBOutlet UILabel *loadingLabel;
    IBOutlet UIActivityIndicatorView *loadingSpinner;
    IBOutlet UIButton *loadingButton;
    NSMutableArray *results;
}

@property (nonatomic, strong) SnapCL *locationController;
@property (nonatomic, strong) NSMutableArray *results;

- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
- (IBAction)searchForEvents:(id)sender;

@end
