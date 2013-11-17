//
//  SnapEventPhotoListViewController.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-13.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapEventPhotoListViewController.h"
#import "SnapPhotoShareViewController.h"
#import "SnapEventPhotoListCell.h"
#import "SnapApiClient.h"

@implementation SnapEventPhotoListViewController {
    UIBarButtonItem *_cameraRoll;
}

// declare & synthesize some class properties
static NSString *cellIdentifier = @"eventPhotoListCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"EventPhotoList"; // Google Analytics
	// Do any additional setup after loading the view.
    
    // init the arrays if they are null
    if (self.api_photos == nil) {
        self.api_photos = [NSMutableArray array];
    }
    if (self.photos == nil) {
        self.photos = [NSMutableArray array];
    }

    // add camera roll icon
    _cameraRoll = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Gallery_BTN"]
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(cameraRoll:)];
    self.navigationItem.rightBarButtonItems = @[_cameraRoll];

    // add iOS pull to refresh
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
}

// some view tweaks before it's displayed
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // We need to force the status bar for the edge case of the UIImagePickerController changing
    // the source type while being displayed. Changing the source type while it's being displayed
    // hides the status bar. This fixes it.
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

// this loads the camera after the view appeared (a trick to hide the loading)
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // initialize the camera
    self.camera = [SnapCamera sharedInstance];
    [self refresh:_refreshControl];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SnapEventPhotoListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    // get the photo
    SnapPhoto *photo = [self.photos objectAtIndex:indexPath.row];

    // initialize if null
    if (cell == nil) {
        cell = [[SnapEventPhotoListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    // set the data
    cell.uiPhotoCaption.text = photo.caption;
    if (photo.author_name.length > 0) {
        cell.uiPhotoAuthor.text = photo.author_name;
    }

    // set the image string
    NSString *photoAbsolutePath;

    // if it's the original screen resolution
    NSString *size = @"crop";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if([[UIScreen mainScreen] scale] == 1.0f){
           size = @"250x250";
        }
        // else retina
        else {
            size = @"500x500";
        }
    } else {
        // TODO ipad here 
    }
    
    // set the image to be auto loaded
    photoAbsolutePath = [NSString stringWithFormat:@"%@%@?size=%@", [SnapAPIBaseURL substringToIndex:(SnapAPIBaseURL.length - 1)], photo.resource_uri, size];
    [cell.uiPhoto setImageWithSignedURL:[NSURL URLWithString:photoAbsolutePath] placeholderImage:[UIImage imageNamed:@"PlaceholderImage"]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Row modifications
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // this shouldn't be hard
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    return cell.frame.size.height;
}

#pragma mark - IBActions
- (IBAction)loadMore:(UIButton*)sender
{
    // load more photos
    DLog(@"'load more' button press");
    [self loadMoreImages:10];
}

- (IBAction)takePhoto:(UIButton*)sender
{
    // launch the camera
    DLog(@"'take photo' button press");
    [self.camera startCameraControllerFromViewController:self usingDelegate:self withSourceType:UIImagePickerControllerSourceTypeCamera];
    [Analytics sendScreenName:@"Camera"];
}

- (IBAction)cameraRoll:(UIButton*)sender
{
    // launch the camera
    DLog(@"'image gallery' button press");
    [self.camera startCameraControllerFromViewController:self usingDelegate:self withSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [Analytics sendScreenName:@"Gallery"];
}

#pragma mark - Camera delegate
// For responding to the user tapping Cancel.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    DLog(@"dismiss the imagePicker");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *previewImage;

    // Handle a still image capture
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {

        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        // get the original images width and height
        CGFloat originalWidth = originalImage.size.width;
        CGFloat originalHeight = originalImage.size.height;
        
        // crop coordinates
        CGFloat squareLength = 0.0f;
        if (originalWidth > originalHeight) {
            squareLength = originalHeight;
        } else {
            squareLength = originalWidth;
        }
        CGRect crop; // this will hold our orientation corrected crop values
        
        // modify the crop rectangle based on EXIF data in the original image regarding orientation
        if (originalImage.imageOrientation == UIImageOrientationUp) {
            // NOTHING, the sensor is in the upright position
            crop = CGRectMake((originalWidth - squareLength) / 2.0, 0, squareLength, squareLength);
        } else if (originalImage.imageOrientation == UIImageOrientationDown) {
            // the sensor was rotated 180 degrees CW/CCW
            crop = CGRectMake((originalWidth - squareLength) / 2.0, 0, squareLength, squareLength);
        }
        else if (originalImage.imageOrientation == UIImageOrientationLeft) {
            // the sersor was rotated 90 degrees CCW
            crop = CGRectMake((originalHeight - squareLength) / 2.0, 0, squareLength, squareLength);
            
        } else if (originalImage.imageOrientation == UIImageOrientationRight) {
            // the sensor wa rotated 90 degrees CW
            crop = CGRectMake((originalHeight - squareLength) / 2.0, 0, squareLength, squareLength);
        }
        
        // apply the cropping to the image and get a reference to the transformation
        CGImageRef imageRef = CGImageCreateWithImageInRect([originalImage CGImage], crop);
        // rasterize the image and free up the image reference
        previewImage = [UIImage imageWithCGImage:imageRef scale:originalImage.scale orientation:originalImage.imageOrientation];
        CGImageRelease(imageRef);

        // Save the original image to the camera roll if it wasn't
        // originally selected from the camera roll
        if (picker.sourceType != UIImagePickerControllerSourceTypePhotoLibrary && picker.sourceType != UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
            UIImageWriteToSavedPhotosAlbum (originalImage, nil, nil ,nil);
        }

        // start the share screen
        UIStoryboard *storyboard = [self.navigationController storyboard];
        SnapPhotoShareViewController *snapPhotoVC = (SnapPhotoShareViewController *)[storyboard instantiateViewControllerWithIdentifier:@"photoShareController"];
        snapPhotoVC.event = self.event;
        snapPhotoVC.photoImage = originalImage;
        snapPhotoVC.previewImage = previewImage;
        [picker dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:snapPhotoVC animated:YES completion:nil];
        }];
    }
}


#pragma mark - UI Manipulation
- (void)loadMoreImages:(NSInteger)count {
    // load more images
    if (self.api_photos.count > 0) {
        // make sure the OMG message is hidden
        self.uiNoPhotos.hidden = YES;
        
        NSInteger limit = ((self.api_photos.count - self.photos.count) <= abs(count)) ? (self.api_photos.count - self.photos.count):abs(count);
        
        NSMutableArray *paths = [NSMutableArray arrayWithCapacity:limit];
        for (int i=0; i<limit; i++) {
            NSInteger nextIndex = self.photos.count;
            [self.photos addObject:[self.api_photos objectAtIndex:nextIndex]];
            [paths addObject:[NSIndexPath indexPathForRow:nextIndex inSection:0]];
        }
        [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
    } else {
        self.uiNoPhotos.hidden = NO;
    }
}

# pragma mark - API
- (void)refresh:(UIRefreshControl *)sender {
    // setup the refresh spinner
    if (!sender.refreshing) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        [activityIndicator startAnimating];
        self.navigationItem.rightBarButtonItems = @[_cameraRoll, barButton];
    }
    // start the refresh control
    [sender beginRefreshing];
    
    NSDictionary *params = @{
        @"event": [SnapApiClient getIdAsStringFromResourceUri:self.event.resource_uri],
        @"streamable": @"true"
    };

    // some variables to store data in
    NSMutableArray *tempPhotoArray = [NSMutableArray array];
    [[SnapApiClient sharedInstance] getPath:@"photo/" parameters:params
        success:^(AFHTTPRequestOperation *operation, id response) {
            DLog(@"we got an API response");
            // hydrate the response into objects
            for (id newphoto in [response valueForKeyPath:@"objects"]) {
                SnapPhoto *photo = [[SnapPhoto alloc] initWithDictionary:newphoto];
                [tempPhotoArray addObject:photo];
            }
            
            // there already are photos
            // figure out how many are new and add them to the api array
            if (self.api_photos.count > 0) {
                DLog(@"we already have some photos");
                // get the current first API photo and it's id
                SnapPhoto *firstPhoto = [self.api_photos objectAtIndex:0];
                NSInteger firstPhotoId = [SnapApiClient getIdAsIntegerFromResourceUri:firstPhoto.resource_uri];
                
                DLog(@"loop through and merge");
                // get the new photos
                NSMutableArray *newPhotoArray = [NSMutableArray array];
                SnapPhoto *tempPhoto;
                for (int i=(tempPhotoArray.count-1); i>=0; i--) {
                    // get the new photo
                    tempPhoto = [tempPhotoArray objectAtIndex:i];
                    NSInteger tempPhotoId = [SnapApiClient getIdAsIntegerFromResourceUri:tempPhoto.resource_uri];
                    
                    // if the temp photo isn't in the API array
                    if (tempPhotoId > firstPhotoId) {
                        [newPhotoArray insertObject:tempPhoto atIndex:0];
                        [self.api_photos insertObject:tempPhoto atIndex:0];
                        [self.photos insertObject:tempPhoto atIndex:0];
                    }
                }
                
                DLog(@"about to update the viewTable");
                NSMutableArray *paths = [NSMutableArray arrayWithCapacity:newPhotoArray.count];
                for (int i=0; i<newPhotoArray.count; i++) {
                    [paths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
            }
            // there are no photos
            else {
                self.api_photos = tempPhotoArray;
                [self loadMoreImages:50];
            }

            // end refresh
            self.navigationItem.rightBarButtonItems = @[_cameraRoll];
            [sender endRefreshing];
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error fetching photos!");
            DLog(@"%@", error);

            // end refresh
            self.navigationItem.rightBarButtonItems = @[_cameraRoll];
            [sender endRefreshing];
        }
     ];
}

@end
