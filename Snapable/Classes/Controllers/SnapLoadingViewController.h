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
}

- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;

@end