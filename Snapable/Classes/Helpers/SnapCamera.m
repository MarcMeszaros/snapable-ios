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

- (BOOL)startCameraControllerFromViewController:(UIViewController*)controller usingDelegate:(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate withSourceType:(UIImagePickerControllerSourceType)sourceType {

    // if we fail the runtime check for camera availibility, give up
    if (([UIImagePickerController isSourceTypeAvailable:sourceType] == NO) || (delegate == nil) || (controller == nil)) {
        return NO;
    }
    
    // make the source type of the picker
    self.cameraUI.sourceType = sourceType;
    if (self.cameraUI.sourceType == UIImagePickerControllerSourceTypeCamera) {
        self.cameraUI.cameraFlashMode = self.flashMode;
    }
    
    // only allow images
    self.cameraUI.mediaTypes = @[(NSString *)kUTTypeImage];

    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    self.cameraUI.allowsEditing = NO;
    self.cameraUI.delegate = delegate;
    [self.cameraUI setWantsFullScreenLayout:NO];

    [controller presentViewController:self.cameraUI animated:YES completion:nil];
    return YES;
}

@end
