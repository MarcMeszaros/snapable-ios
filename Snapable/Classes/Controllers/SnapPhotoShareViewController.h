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

    IBOutlet UIImageView *uiPhotoPreview;
    IBOutlet UITextField *uiPhotoCaption;
    IBOutlet UIProgressView *uiPhotoUploadProgress;
    IBOutlet UIActivityIndicatorView *uiCaptionUploadSpinner;
    IBOutlet UIButton *uiUploadDone;
    IBOutlet UIButton *uiUploadRetry;
    IBOutlet UIButton *uiBack;
    IBOutlet UIView *uiUploadViewGroup;
    IBOutlet UIView *uiUploadProgressViewGroup;
    
    AFHTTPRequestOperation *uploadOperation;
}

@property (nonatomic, strong) SnapEvent *event;
@property (nonatomic) NSInteger photoId;
@property (nonatomic, strong) UIImage *photoImage;
@property (nonatomic, strong) UIImageView *uiPhotoPreview;
@property (nonatomic, strong) UITextField *uiPhotoCaption;
@property (nonatomic, strong) UIProgressView *uiPhotoUploadProgress;
@property (nonatomic, strong) UIActivityIndicatorView *uiCaptionUploadSpinner;
@property (nonatomic, strong) UIButton *uiUploadDone;
@property (nonatomic, strong) UIButton *uiUploadRetry;
@property (nonatomic, strong) UIButton *uiBack;
@property (nonatomic, strong) UIView *uiUploadViewGroup;
@property (nonatomic, strong) UIView *uiUploadProgressViewGroup;
@property (nonatomic, strong) AFHTTPRequestOperation *uploadOperation;

- (void)uploadPhotoStart;
- (void)uploadPhotoCancel;

@end
