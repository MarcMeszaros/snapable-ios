//
//  SnapCamera.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-07.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapCamera.h"

@implementation SnapCamera

@synthesize cameraUI;
@synthesize uiFlash;
@synthesize uiSwitchCamera;

+ (id)sharedInstance {
    static SnapCamera *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SnapCamera alloc] init]; // init the object
        _sharedInstance.cameraUI = [[UIImagePickerController alloc] init]; // init the camera ui
    });

    return _sharedInstance;
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller usingDelegate: (id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate {

    // if we fail the runtime check for camera availibility
    // give up
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    // make the source time the camera
    self.cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // only allow images
    self.cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];

    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    self.cameraUI.allowsEditing = NO;

    self.cameraUI.delegate = delegate;
    
    // load up our custom overlay
    UIView *overlay = [UIView alloc];
    overlay = [[[NSBundle mainBundle] loadNibNamed:@"CameraOverlay" owner:self options:nil] objectAtIndex:0];
    // add the custom overlay to the image picker
    self.cameraUI.cameraOverlayView = overlay;
    self.uiFlash = (UIButton *)[overlay viewWithTag:TAG_uiFlash];
    self.uiSwitchCamera = (UIButton *)[overlay viewWithTag:TAG_uiSwitchCamera];
    
    // check if flash is available
    BOOL flashAvailable = [UIImagePickerController isFlashAvailableForCameraDevice:self.cameraUI.cameraDevice];
    DLog(@"flash available: %d", flashAvailable);
    
    // show the flash button
    if (flashAvailable == YES) {
        // set the image based on the flash mode
        switch (self.cameraUI.cameraFlashMode) {
            case UIImagePickerControllerCameraFlashModeOff:
                // set the "Off" image
                [self.uiFlash setImage:[UIImage imageNamed:@"buttonFlashOff.png"] forState:UIControlStateNormal];
                break;
            case UIImagePickerControllerCameraFlashModeAuto:
                // set the "Auto" image
                [self.uiFlash setImage:[UIImage imageNamed:@"buttonFlashAuto.png"] forState:UIControlStateNormal];
                break;
            case UIImagePickerControllerCameraFlashModeOn:
                // set the "On" image
                [self.uiFlash setImage:[UIImage imageNamed:@"buttonFlashOn.png"] forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
        
        // enable button switching
        [self.uiFlash addTarget:self action:@selector(changeFlashMode:) forControlEvents:UIControlEventAllTouchEvents];

        // unhide the flash button
        self.uiFlash.hidden = NO;
    }
    

    [controller presentViewController:self.cameraUI animated:YES completion:nil];
    return YES;
}

- (void)changeFlashMode:(id)sender {
    // set the image based on the flash mode
    switch (self.cameraUI.cameraFlashMode) {
        case UIImagePickerControllerCameraFlashModeOff:
            // set the "Off" image
            self.cameraUI.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
            [self.uiFlash setImage:[UIImage imageNamed:@"buttonFlashAuto.png"] forState:UIControlStateNormal];
            break;
        case UIImagePickerControllerCameraFlashModeAuto:
            // set the "Auto" image
            self.cameraUI.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
            [self.uiFlash setImage:[UIImage imageNamed:@"buttonFlashOn.png"] forState:UIControlStateNormal];
            break;
        case UIImagePickerControllerCameraFlashModeOn:
            // set the "On" image
            self.cameraUI.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
            [self.uiFlash setImage:[UIImage imageNamed:@"buttonFlashOff.png"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

@end
