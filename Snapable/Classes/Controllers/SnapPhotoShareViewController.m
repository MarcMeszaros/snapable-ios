//
//  SnapPhotoShareViewController.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-16.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapAppDelegate.h"
#import "SnapPhotoShareViewController.h"
#import "Toast+UIView.h"

@implementation SnapPhotoShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"PhotoUpload"; // Google Analytics
	// Do any additional setup after loading the view.

    // set the preview image
    self.uiPhotoPreview.image = self.previewImage;
    self.uiBack.enabled = NO;

    // start uploading the photo
    [self uploadPhotoStart];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIAction

- (IBAction)doneButton:(id)sender {
    if (self.uiPhotoCaption.text && self.uiPhotoCaption.text.length > 0) {
        // update the photo data (ie. caption)
        // parameters
        NSString *apiPath = [NSString stringWithFormat:@"photo/%d/", self.photoId];
        NSDictionary *params = @{
            @"caption": self.uiPhotoCaption.text
        };

        // start spinner
        self.uiCaptionUploadSpinner.hidden = NO;
        self.uiUploadDone.hidden = YES;

        // call the api
        [[SnapApiClient sharedInstance] patchPath:apiPath parameters:params
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
              // close the window
              [self dismissViewControllerAnimated:YES completion:nil];
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              // just log the failure
              ALog(@"Error updating photo data!");
              DLog(@"%@", error);
              [self.view makeToast:@"Failed to update caption." duration:3.0 position:@"center"];
              self.uiBack.enabled = YES;
              self.uiCaptionUploadSpinner.hidden = YES;
              self.uiUploadDone.hidden = NO;
            }
         ];
    } else {
        // close the window
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelUploadButton:(id)sender {
    [self uploadPhotoCancel];
    self.uiUploadProgressViewGroup.hidden = YES;
    self.uiUploadRetry.hidden = NO;
    self.uiBack.enabled = YES;
}

- (IBAction)retryUploadButton:(id)sender {
    self.uiUploadRetry.hidden = YES;
    self.uiUploadProgressViewGroup.hidden = NO;
    self.uiBack.enabled = NO;
    [self uploadPhotoStart];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Uploading

- (void)uploadPhotoStart {
    // try and get local guest info
    // open local storage
    SnapAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.database open];
    
    // query the database
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM event_credentials WHERE id = %d", [SnapApiClient getIdAsIntegerFromResourceUri:self.event.resource_uri]];
    FMResultSet *results = [delegate.database executeQuery:query];

    // parameters
    NSDictionary *params = nil;
    if ([results next] && [results intForColumn:@"guest_id"] > 0) {
        params = @{
            @"event": self.event.resource_uri,
            @"guest": [NSString stringWithFormat:@"/%@/guest/%d/", SnapAPIVersion, [results intForColumn:@"guest_id"]]
        };
    } else {
        params = @{
            @"event": self.event.resource_uri
        };
    }
    // close the database
    [delegate.database close];
    
    // upload the image
    SnapApiClient *httpClient = [SnapApiClient sharedInstance];
    NSData *imageData = UIImageJPEGRepresentation(self.photoImage, 0.5);
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"photo/" parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:@"img" mimeType:@"image/jpeg"];
    }];
    
    // sign the request
    request = [httpClient signRequest:request];
    
    // setup the upload
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    // set the progress update
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        self.uiPhotoUploadProgress.progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    }];
    
    // handle success/failure
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // HTTP success code
        if (operation.response.statusCode == 201) {
            // success
            NSDictionary *responseHeaders = operation.response.allHeaderFields;
            
            // the path to the create photo resource
            NSString *photoResourceLocation = [responseHeaders valueForKey:@"Location"];
            DLog(@"Location: %@", photoResourceLocation);
            self.photoId = [SnapApiClient getIdAsIntegerFromResourceUri:photoResourceLocation];
            
            // toggle the upload view and done button
            self.uiUploadViewGroup.hidden = YES;
            self.uiUploadDone.hidden = NO;
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // just log the failure
        ALog(@"Error uploading photo!");
        DLog(@"%@", error);
        [self.view makeToast:@"Failed to upload photo." duration:3.0 position:@"center"];
        self.uiUploadProgressViewGroup.hidden = YES;
        self.uiUploadRetry.hidden = NO;
        self.uiBack.enabled = YES;
    }];
    
    // start uploading the image
    self.uploadOperation = operation;
    [[httpClient operationQueue] addOperation:operation];
}

- (void)uploadPhotoCancel {
    [self.uploadOperation cancel];
    self.uploadOperation = nil;
}

#pragma mark - Keyboard Fixes to not Hide Content
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextField:textField up:NO];
}

- (void) animateTextField:(UITextField *)textField up:(BOOL)up {
    const int movementDistance = 60; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed

    int movement = (up ? -movementDistance : movementDistance);

    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

@end
