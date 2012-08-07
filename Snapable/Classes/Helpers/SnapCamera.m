//
//  SnapCamera.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-07.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapCamera.h"

@implementation SnapCamera

+ (id)sharedInstance {
    static SnapCamera *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SnapCamera alloc] init];
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
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // only allow images
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];

    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;

    cameraUI.delegate = delegate;

    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}

@end
