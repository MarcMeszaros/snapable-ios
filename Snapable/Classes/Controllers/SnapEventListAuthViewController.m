//
//  SnapEventListAuthViewController.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-28.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapAppDelegate.h"
#import "SnapEventListAuthViewController.h"
#import "Toast+UIView.h"
#import "SnapApiClient.h"

@interface SnapEventListAuthViewController ()

@end

@implementation SnapEventListAuthViewController

@synthesize event;
@synthesize guest;
@synthesize parentVC;
@synthesize uiName;
@synthesize uiEmail;
@synthesize uiPin;
@synthesize uiPinViewGroup;
@synthesize uiGuestInfoViewGroup;

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
    // if we match the pin
    if ([self.uiPin.text compare:self.event.pin] == NSOrderedSame) {
        // the pin group is hidden, try and process email and name
        if (self.uiPinViewGroup.hidden) {
            // parameters
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [SnapApiClient getIdAsStringFromResourceUri:self.event.resource_uri], @"event",
                                    self.uiEmail.text, @"email",
                                    nil];
            
            // upload the image
            SnapApiClient *httpClient = [SnapApiClient sharedInstance];
            [httpClient getPath:@"guest/" parameters:params
                        success:^(AFHTTPRequestOperation *operation, id response) {
                            // handle a success
                            if ([[response valueForKeyPath:@"meta.total_count"] integerValue] == 1) {
                                NSArray *guests = [response valueForKeyPath:@"objects"];
                                self.guest = [[SnapGuest alloc] initWithDictionary:[guests objectAtIndex:0]];
                                DLog(@"guest: %@", self.guest.email);
                            }
                            
                            // if we match the email
                            if (self.guest != nil && [self.uiEmail.text compare:self.guest.email] == NSOrderedSame) {
                                // TODO save the guest info
                            }
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            // handle failure
                            ALog(@"Error trying to get the guest");
                            DLog(@"Error: %@", error);
                        }
             ];
            
            // save the credentuals and go to the next sceen
            [self updateOrCreateEventCredentials];
            [self dismissViewControllerAnimated:YES completion:^{
                DLog(@"try and perform segue");
                [self.parentVC performSegueWithIdentifier:@"eventListPhotoSegue" sender:self.parentVC];
            }];
        }
        
        // hide the pin stuff and show the guest info
        self.uiPinViewGroup.hidden = YES;
        self.uiGuestInfoViewGroup.hidden = NO;
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

// update or create the information cache
- (void)updateOrCreateEventCredentials {
    // open local storage
    SnapAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.database open];
    
    // query the database
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM event_credentials WHERE id = %d", [SnapApiClient getIdAsIntegerFromResourceUri:self.event.resource_uri]];
    FMResultSet *results = [delegate.database executeQuery:query];
    
    // the event credentials already exists, update it
    if ([results next]) {
        NSString *query = [NSString stringWithFormat:@"UPDATE event_credentials SET email='%@', name='%@', pin='%@' WHERE id = %d",
                           self.uiEmail.text,
                           self.uiName.text,
                           self.event.pin,
                           [SnapApiClient getIdAsIntegerFromResourceUri:self.event.resource_uri]];
        [delegate.database executeUpdate:query];
    }
    // there is no event credentials, create it
    else {
        NSString *query = [NSString stringWithFormat:@"INSERT INTO event_credentials(id, email, name, pin) VALUES (%d, '%@', '%@', '%@')",
                           [SnapApiClient getIdAsIntegerFromResourceUri:self.event.resource_uri],
                           self.uiEmail.text,
                           self.uiName.text,
                           self.event.pin];
        [delegate.database executeUpdate:query];
    }
    
    // close the database
    [delegate.database close];
}

@end
