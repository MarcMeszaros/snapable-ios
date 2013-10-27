//
//  SnapCamera.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-07.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define TAG_uiFlash 1
#define TAG_uiSwitchCamera 2
#define TAG_uiCameraRoll 3

@interface SnapCamera : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *cameraUI;
@property (nonatomic) NSInteger flashMode;


+ (id)sharedInstance;

- (BOOL)startCameraControllerFromViewController:(UIViewController*)controller
                                   usingDelegate:(id <UIImagePickerControllerDelegate,
                                                  UINavigationControllerDelegate>)delegate
                                 withSourceType:(UIImagePickerControllerSourceType)sourceType;

@end
