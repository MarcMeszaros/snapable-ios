//
//  SnapPhotoShareViewController.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-16.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnapPhotoShareViewController : UIViewController <UITextFieldDelegate> {
    IBOutlet UITextField *uiImageCaption;
}

@property (nonatomic, strong) UITextField *uiImageCaption;

@end
