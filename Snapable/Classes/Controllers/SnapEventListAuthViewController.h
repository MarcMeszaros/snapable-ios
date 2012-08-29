//
//  SnapEventListAuthViewController.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-28.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnapEvent.h"

@interface SnapEventListAuthViewController : UIViewController <UITextFieldDelegate> {
    SnapEvent *event;
    UIViewController *parenVC;
    
    IBOutlet UITextField *uiEmail;
    IBOutlet UITextField *uiPin;
    IBOutlet UIView *uiPinViewGroup;
}

@property (nonatomic, strong) SnapEvent *event;
@property (nonatomic, strong) UIViewController *parentVC;
@property (nonatomic, strong) UITextField *uiEmail;
@property (nonatomic, strong) UITextField *uiPin;
@property (nonatomic, strong) UIView *uiPinViewGroup;

@end
