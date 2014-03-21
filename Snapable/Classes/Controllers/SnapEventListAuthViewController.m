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

@implementation SnapEventListAuthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"EventAuth"; // Google Analytics
	// Do any additional setup after loading the view.
    if (self.event.public == true) {
        // hide the pin stuff and show the guest info
        self.uiPinViewGroup.hidden = YES;
        self.uiGuestInfoViewGroup.hidden = NO;
        self.uiContinueButton.hidden = NO;
    }
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

// try and authenticate the user
- (IBAction)authenticateButton:(id)sender {
    // if we match the pin
    if (self.event.public == true || [self.uiPin.text compare:self.event.pin] == NSOrderedSame) {
        // the pin group is hidden, try and process email and name
        if (self.uiPinViewGroup.hidden) {
            // parameters
            NSMutableDictionary *params = @{
                @"event": [SnapApiClient getIdAsStringFromResourceUri:self.event.resource_uri]
            }.mutableCopy;
            if (self.uiEmail.text != nil && [self.uiEmail.text length] > 0) {
                [params setObject:self.uiEmail.text forKey:@"email"];
            }

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
                                    NSString *putPath = [NSString stringWithFormat:@"guest/%ld/", (long)self.guest.id];
                                    NSDictionary *params = @{
                                        @"name": self.uiName.text
                                    };
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
                                // make an API call to create guest
                                NSDictionary *params = @{
                                    @"event": self.event.resource_uri,
                                    @"name": self.uiName.text,
                                    @"email": self.uiEmail.text
                                };

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
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM event_credentials WHERE id = %ld", (long)eventId];
    FMResultSet *results = [delegate.database executeQuery:query];
    
    // the event credentials already exists, update it
    if ([results next]) {
        NSString *query = nil;
        if (guestId <= 0) {
            query = [NSString stringWithFormat:@"UPDATE event_credentials SET email='%@', name='%@', pin='%@' WHERE id = %ld",
                self.uiEmail.text, self.uiName.text, self.event.pin, (long)eventId];
        } else {
            query = [NSString stringWithFormat:@"UPDATE event_credentials SET guest_id = %ld, email='%@', name='%@', pin='%@' WHERE id = %ld",
                (long)guestId, self.uiEmail.text, self.uiName.text, self.event.pin, (long)eventId];
        }
        [delegate.database executeUpdate:query];
    }
    // there is no event credentials, create it
    else {
        NSString *query = nil;
        if (guestId <= 0) {
            query = [NSString stringWithFormat:@"INSERT INTO event_credentials(id, email, name, pin) VALUES (%ld, '%@', '%@', '%@')",
                (long)eventId, self.uiEmail.text, self.uiName.text, self.event.pin];
        } else {
            query = [NSString stringWithFormat:@"INSERT INTO event_credentials(id, guest_id, email, name, pin) VALUES (%ld, %ld, '%@', '%@', '%@')",
                (long)eventId, (long)guestId, self.uiEmail.text, self.uiName.text, self.event.pin];
        }
        [delegate.database executeUpdate:query];
    }
    
    // close the database
    [delegate.database close];
}

@end
