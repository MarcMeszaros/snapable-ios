//
//  SnapPhotoShareViewController.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-16.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SnapApiClient.h"
#import "SnapEvent.h"
#import "SnapPhoto.h"


@interface SnapPhotoShareViewController : UIViewController <UITextFieldDelegate> {
    SnapEvent *event;
    NSInteger photoId;
    UIImage *photoImage;
    NSString *photoCaption;
    
    IBOutlet UIImageView *uiPhotoPreview;
    IBOutlet UITextField *uiPhotoCaption;
    IBOutlet UIProgressView *uiPhotoUploadProgress;
    IBOutlet UIButton *uiUploadDone;
    IBOutlet UIView *uiUploadViewGroup;
}

@property (nonatomic, strong) SnapEvent *event;
@property (nonatomic) NSInteger photoId;
@property (nonatomic, strong) UIImage *photoImage;
@property (nonatomic, strong) NSString *photoCaption;
@property (nonatomic, strong) UIImageView *uiPhotoPreview;
@property (nonatomic, strong) UITextField *uiPhotoCaption;
@property (nonatomic, strong) UIProgressView *uiPhotoUploadProgress;
@property (nonatomic, strong) UIButton *uiUploadDone;
@property (nonatomic, strong) UIView *uiUploadViewGroup;

@end
