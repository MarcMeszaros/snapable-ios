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
@synthesize uiContinueButton;

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
    if (self.event.public == true) {
        // hide the pin stuff and show the guest info
        self.uiPinViewGroup.hidden = YES;
        self.uiGuestInfoViewGroup.hidden = NO;
        self.uiContinueButton.hidden = NO;
        //[[GANTracker sharedTracker] trackPageview:@"/guestInfo" withError:nil];
    } else {
        //[[GANTracker sharedTracker] trackPageview:@"/guestPin" withError:nil];
    }
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
    if (self.event.public == true || [self.uiPin.text compare:self.event.pin] == NSOrderedSame) {
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
                                
                                // if we match the email
                                if ([self.uiEmail.text compare:self.guest.email] == NSOrderedSame) {
                                    // save the guest id
                                    [self updateOrCreateEventCredentialsWithEventId:[SnapApiClient getIdAsIntegerFromResourceUri:self.event.resource_uri] withGuestId:self.guest.id];
                                    
                                    // update the guest
                                    NSString *putPath = [NSString stringWithFormat:@"guest/%d/", self.guest.id];
                                    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                            self.uiName.text, @"name",
                                            nil];
                                    [httpClient putPath:putPath parameters:params
                                            success:^(AFHTTPRequestOperation *operation, id response) {
                                                DLog(@"successfuly updated guest name");
                                            }
                                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                ALog(@"Error updating guest info.");
                                                DLog(@"Error: %@", error);
                                            }
                                     ];
                                }
                            }
                            // else create the guest info on the API
                            else if (self.uiEmail.text.length > 0 || self.uiName.text.length > 0) {
                                // guest type
                                NSString *guestType = nil;
                                if (self.event.public == true) {
                                    guestType = [NSString stringWithFormat:@"/%@/type/6/", SnapAPIVersion];
                                } else {
                                    guestType = [NSString stringWithFormat:@"/%@/type/5/", SnapAPIVersion];
                                }

                                // make an API call to create guest
                                NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                        self.event.resource_uri, @"event",
                                        guestType, @"type",
                                        self.uiName.text, @"name",
                                        self.uiEmail.text, @"email",
                                        nil];
                                [httpClient postPath:@"guest/" parameters:params
                                    success:^(AFHTTPRequestOperation *operation, id response) {
                                        NSString *locationHeader = [operation.response.allHeaderFields valueForKey:@"Location"];
                                        [self updateOrCreateEventCredentialsWithEventId:[SnapApiClient getIdAsIntegerFromResourceUri:self.event.resource_uri] withGuestId:[SnapApiClient getIdAsIntegerFromResourceUri:locationHeader]];
                                    }
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        ALog(@"Failed to create new guest.");
                                        DLog(@"Error: %@", error);
                                    }
                                 ];
                            }
                            // just save the pin
                            else {
                                [self updateOrCreateEventCredentialsWithEventId:[SnapApiClient getIdAsIntegerFromResourceUri:self.event.resource_uri] withGuestId:0];
                            }
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            // handle failure
                            ALog(@"Error trying to get the guest");
                            DLog(@"Error: %@", error);
                            [self updateOrCreateEventCredentialsWithEventId:[SnapApiClient getIdAsIntegerFromResourceUri:self.event.resource_uri] withGuestId:0];
                        }
             ];
            
            // save the credentials and go to the next sceen
            [self dismissViewControllerAnimated:YES completion:^{
                DLog(@"try and perform segue");
                [self.parentVC performSegueWithIdentifier:@"eventListPhotoSegue" sender:self.parentVC];
            }];
        }
        
        // hide the pin stuff and show the guest info
        self.uiPinViewGroup.hidden = YES;
        self.uiGuestInfoViewGroup.hidden = NO;
        self.uiContinueButton.hidden = NO;
        //[[GANTracker sharedTracker] trackPageview:@"/guestInfo" withError:nil];
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
    // if the pin is still visible, try and authenticate
    if (self.uiPinViewGroup.hidden == NO) {
        [self authenticateButton:self];
    }

    return YES;
}

// update or create the information cache
- (void)updateOrCreateEventCredentialsWithEventId:(NSInteger)eventId withGuestId:(NSInteger)guestId {
    // open local storage
    SnapAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.database open];
    
    // query the database
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM event_credentials WHERE id = %d", eventId];
    FMResultSet *results = [delegate.database executeQuery:query];
    
    // the event credentials already exists, update it
    if ([results next]) {
        NSString *query = nil;
        if (guestId <= 0) {
            query = [NSString stringWithFormat:@"UPDATE event_credentials SET email='%@', name='%@', pin='%@' WHERE id = %d",
                self.uiEmail.text, self.uiName.text, self.event.pin, eventId];
        } else {
            query = [NSString stringWithFormat:@"UPDATE event_credentials SET guest_id = %d, email='%@', name='%@', pin='%@' WHERE id = %d",
                guestId, self.uiEmail.text, self.uiName.text, self.event.pin, eventId];
        }
        [delegate.database executeUpdate:query];
    }
    // there is no event credentials, create it
    else {
        NSString *query = nil;
        if (guestId <= 0) {
            query = [NSString stringWithFormat:@"INSERT INTO event_credentials(id, email, name, pin) VALUES (%d, '%@', '%@', '%@')",
                eventId, self.uiEmail.text, self.uiName.text, self.event.pin];
        } else {
            query = [NSString stringWithFormat:@"INSERT INTO event_credentials(id, guest_id, email, name, pin) VALUES (%d, %d, '%@', '%@', '%@')",
                eventId, guestId, self.uiEmail.text, self.uiName.text, self.event.pin];
        }
        [delegate.database executeUpdate:query];
    }
    
    // close the database
    [delegate.database close];
}

@end
