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


@interface SnapPhotoShareViewController : GAITrackedViewController <UITextFieldDelegate>

@property (nonatomic, strong) SnapEvent *event;
@property (nonatomic) NSInteger photoId;
@property (nonatomic, strong) UIImage *photoImage;
@property (nonatomic, strong) UIImage *previewImage;
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
