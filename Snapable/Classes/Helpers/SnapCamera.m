//
//  SnapCamera.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-07.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapCamera.h"
#import "SnapImagePicker.h"

@implementation SnapCamera

@synthesize cameraUI;
@synthesize uiCameraRoll;
@synthesize flashMode;

+ (id)sharedInstance {
    static SnapCamera *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SnapCamera alloc] init]; // init the object
        _sharedInstance.cameraUI = [[SnapImagePicker alloc] init]; // init the camera ui
        _sharedInstance.flashMode = UIImagePickerControllerCameraFlashModeAuto;
    });

    return _sharedInstance;
}

- (BOOL)startCameraControllerFromViewController:(UIViewController*)controller usingDelegate:(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate {

    // if we fail the runtime check for camera availibility
    // give up
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) || (delegate == nil) || (controller == nil)) {
        return NO;
    }
    
    // make the source time the camera
    self.cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.cameraUI.cameraFlashMode = self.flashMode;
    
    // only allow images
    self.cameraUI.mediaTypes = @[(NSString *)kUTTypeImage];

    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    self.cameraUI.allowsEditing = NO;
    self.cameraUI.delegate = delegate;
    
    // load up our custom overlay
    UIView *overlay = [UIView alloc];
    overlay = [[[NSBundle mainBundle] loadNibNamed:@"CameraOverlay" owner:self options:nil] objectAtIndex:0];
    // add the custom overlay to the image picker
    self.cameraUI.cameraOverlayView = overlay;
    self.uiCameraRoll = (UIButton *)[overlay viewWithTag:TAG_uiCameraRoll];
    [self.cameraUI setWantsFullScreenLayout:NO];

    // setup camera roll button
    [self.uiCameraRoll addTarget:self action:@selector(cameraRoll:) forControlEvents:UIControlEventTouchDown];

    [controller presentViewController:self.cameraUI animated:YES completion:nil];
    return YES;
}

// change the UI Picker to use the camera roll
- (void)cameraRoll:(id)sender {
    self.cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

@end
