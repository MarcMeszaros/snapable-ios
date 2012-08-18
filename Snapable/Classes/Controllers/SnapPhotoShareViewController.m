//
//  SnapPhotoShareViewController.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-16.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapPhotoShareViewController.h"

@interface SnapPhotoShareViewController ()

@end

@implementation SnapPhotoShareViewController

@synthesize event;
@synthesize photo;
@synthesize photoImage;
@synthesize uiPhotoPreview;
@synthesize uiPhotoCaption;
@synthesize uiPhotoUploadProgress;

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

    // set the preview image
    DLog(@"photo: %@", self.photoImage);
    DLog(@"photo preview: %@", uiPhotoPreview);
    self.uiPhotoPreview.image = self.photoImage;

    // parameters
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
        self.event.resource_uri, @"event",
        //@"/private_v1/guest/2/", @"guest", // TODO make this not manual or required...
        self.event.type, @"type",
        nil];
    
    // upload the image
    SnapApiClient *httpClient = [SnapApiClient sharedInstance];
    NSData *imageData = UIImageJPEGRepresentation(self.photoImage, 0.8);
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"photo/" parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:@"img" mimeType:@"image/jpeg"];
    }];

    // sign the request
    request = [httpClient signRequest:request];

    // setup the upload
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        DLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        self.uiPhotoUploadProgress.progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    }];
    // upload the image
    [operation start];
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

#pragma mark - UIAction

-(IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

@end
