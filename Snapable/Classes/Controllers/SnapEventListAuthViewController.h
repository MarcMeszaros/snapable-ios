//
//  SnapEventListAuthViewController.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-28.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnapEvent.h"
#import "SnapGuest.h"

@interface SnapEventListAuthViewController : GAITrackedViewController <UITextFieldDelegate>

@property (nonatomic, strong) SnapEvent *event;
@property (nonatomic, strong) SnapGuest *guest;
@property (nonatomic, strong) UIViewController *parentVC;
@property (nonatomic, strong) UITextField *uiName;
@property (nonatomic, strong) UITextField *uiEmail;
@property (nonatomic, strong) UITextField *uiPin;
@property (nonatomic, strong) UIView *uiPinViewGroup;
@property (nonatomic, strong) UIView *uiGuestInfoViewGroup;
@property (nonatomic, strong) UIButton *uiContinueButton;

- (void)updateOrCreateEventCredentialsWithEventId:(NSInteger)eventId withGuestId:(NSInteger)guestId;

@end
