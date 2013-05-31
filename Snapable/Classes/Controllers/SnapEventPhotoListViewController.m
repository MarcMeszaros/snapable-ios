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

static inline double radians (double degrees) {return degrees * M_PI/180;}

@interface SnapEventPhotoListViewController ()

@end

@implementation SnapEventPhotoListViewController

// declare & synthesize some class properties
static NSString *cellIdentifier = @"eventPhotoListCell";
@synthesize event;
@synthesize camera;
@synthesize api_photos;
@synthesize photos = _photos;
@synthesize uiNoPhotos;
@synthesize uiLoadMore;
@synthesize tableView = _tableView;

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
    self.trackedViewName = @"EventPhotoList"; // Google Analytics
	// Do any additional setup after loading the view.
    
    // init the arrays if they are null
    if (self.api_photos == nil) {
        self.api_photos = [NSMutableArray array];
        self.uiLoadMore.hidden = YES;
    }
    if (self.photos == nil) {
        self.photos = [NSMutableArray array];
    }

    // add refresh button
    UIBarButtonItem *button = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                               target:self
                               action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = button;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
    [self refresh];
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
    if([[UIScreen mainScreen] scale] == 1.0f){
       photoAbsolutePath = [NSString stringWithFormat:@"%@%@?size=250x250", [SnapAPIBaseURL substringToIndex:(SnapAPIBaseURL.length - 1)], photo.resource_uri];
    }
    // else retina
    else {
        photoAbsolutePath = [NSString stringWithFormat:@"%@%@?size=500x500", [SnapAPIBaseURL substringToIndex:(SnapAPIBaseURL.length - 1)], photo.resource_uri];
    }
    
    // set the image to be auto loaded
    [cell.uiPhoto setImageWithSignedURL:[NSURL URLWithString:photoAbsolutePath] placeholderImage:[UIImage imageNamed:@"photoDefault.jpg"]];
    
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
- (IBAction) loadMore: (UIButton*) sender
{
    // load more photos
    DLog(@"'load more' button press");
    [self loadMoreImages:10];
}

- (IBAction) takePhoto: (UIButton*) sender
{
    // launch the camera
    DLog(@"'take photo' button press");
    [self.camera startCameraControllerFromViewController:self usingDelegate:self];
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:kGATrackinId]; // Google Analytics
    [tracker sendView:@"Camera"];    
}

#pragma mark - Camera delegate
// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    DLog(@"dismiss the imagePicker");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {

    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *imageToSave;

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
        imageToSave = [UIImage imageWithCGImage:imageRef scale:originalImage.scale orientation:originalImage.imageOrientation];
        CGImageRelease(imageRef);

        // Save the new image (original or edited) to the camera roll if it wasn't
        // originally selected from the camera roll
        if (picker.sourceType != UIImagePickerControllerSourceTypePhotoLibrary || picker.sourceType != UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
            UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        }

        // start the share screen
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        SnapPhotoShareViewController *snapPhotoVC = (SnapPhotoShareViewController *)[storyboard instantiateViewControllerWithIdentifier:@"photoShareController"];
        snapPhotoVC.event = self.event;
        snapPhotoVC.photoImage = imageToSave;
        [picker dismissViewControllerAnimated:YES completion:^{
            [self presentModalViewController:snapPhotoVC animated:YES];
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
        
        // hide the load more button if we can't display any more
        if (self.api_photos.count == self.photos.count) {
            self.uiLoadMore.hidden = YES;
        } else if (self.api_photos.count > self.photos.count) {
            self.uiLoadMore.hidden = NO;
        }
    } else {
        self.uiNoPhotos.hidden = NO;
    }
}

# pragma mark - API
- (void)refresh {
    // setup the refresh spinner
    UIBarButtonItem *refreshButton = self.navigationItem.rightBarButtonItem;
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator startAnimating];
    self.navigationItem.rightBarButtonItem = barButton;

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
        [SnapApiClient getIdAsStringFromResourceUri:self.event.resource_uri], @"event",
        nil];
    
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
                [self loadMoreImages:5];
            }

            // add back the refresh button
            self.navigationItem.rightBarButtonItem = refreshButton;
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error fetching photos!");
            DLog(@"%@", error);

            // add back the refresh button
            self.navigationItem.rightBarButtonItem = refreshButton;
        }
     ];
}

@end
