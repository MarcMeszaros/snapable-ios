//
//  SnapCamera.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-07.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface SnapCamera : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

+ (id)sharedInstance;

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate;

@end
