//
//  SnapEventListAuthViewController.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-28.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapEventListAuthViewController.h"
#import "Toast+UIView.h"

@interface SnapEventListAuthViewController ()

@end

@implementation SnapEventListAuthViewController

@synthesize event;
@synthesize parentVC;
@synthesize uiEmail;
@synthesize uiPin;
@synthesize uiPinViewGroup;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"eventListPhotoSegue"]) {
        // Get destination view
        SnapEventListAuthViewController *vc = [segue destinationViewController];
        
        // Set the selected button in the new view
        vc.event = self.event;
    }
}

#pragma mark - IBAction
// dismiss the auth screen
- (IBAction)backButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

// try and authenticate the user
- (IBAction)authenticateButton:(id)sender {
    //try and authenticate
    
    // if we match the email
    if ([self.uiEmail.text compare:@"marc"] == NSOrderedSame) {
        [self dismissViewControllerAnimated:YES completion:^{
            DLog(@"try and perform segue");
            [self.parentVC performSegueWithIdentifier:@"eventListPhotoSegue" sender:self.parentVC];
        }];
    }
    // we don't match show pin stuff
    else {
        self.uiPinViewGroup.hidden = NO;
    }
    
    // if we match the pin
    if ([self.uiPin.text compare:self.event.pin] == NSOrderedSame) {
        [self dismissViewControllerAnimated:YES completion:^{
            DLog(@"try and perform pin segue");
            [self.parentVC performSegueWithIdentifier:@"eventListPhotoSegue" sender:self.parentVC];
        }];
    }
    // we don't match show pin stuff 
    else if (self.uiPin.text.length > 0) {
        [self.view makeToast:@"The PIN entered was invalid." duration:3.0 position:@"center"];
    }
    
}

#pragma mark -
// hide the keyboard
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
