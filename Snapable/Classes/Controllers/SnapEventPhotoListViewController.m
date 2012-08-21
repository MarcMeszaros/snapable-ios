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

@interface SnapEventPhotoListViewController ()

@end

@implementation SnapEventPhotoListViewController

// declare & synthesize some class properties
static NSString *cellIdentifier = @"eventPhotoListCell";
@synthesize event;
@synthesize camera;
@synthesize api_photos;
@synthesize photos;
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
	// Do any additional setup after loading the view.
    
    // init the arrays if they are null
    if (self.api_photos == nil) {
        self.api_photos = [NSMutableArray array];
    }
    if (self.photos == nil) {
        self.photos = [NSMutableArray array];
    }

    // load up the nib file
    UIView *header = [[UIView alloc] init];
    header = [[[NSBundle mainBundle] loadNibNamed:@"EventPhotoListHeader" owner:self options:nil] objectAtIndex:0];
    // get a reference to the title label and set the text
    UILabel *title = [header.subviews objectAtIndex:0];
    title.text = self.event.title;
    
    // set the nib as the tableview's header
    //self.tableView.tableHeaderView = header;

    // load the images from API
    [self loadImagesFromApi];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

// this loads the camera after the view appeared (a trick to hide the loading)
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // initialize the camera
    self.camera = [SnapCamera sharedInstance];
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
    [cell.uiPhoto setImageWithURL:[NSURL URLWithString:photoAbsolutePath] placeholderImage:[UIImage imageNamed:@"photoDefault.jpg"]];
    
    return cell;
}

// load the images from api
-(void)loadImagesFromApi {
    // get the event photos
    NSInteger event_id = [SnapApiClient getIdFromResourceUri:self.event.resource_uri];
    NSString *request_string = [NSString stringWithFormat:@"photo/?event=%d", event_id];
    
    [[SnapApiClient sharedInstance] getPath:request_string parameters:nil
        success:^(AFHTTPRequestOperation *operation, id response) {
            // hydrate the response into objects
            for (id photos in [response valueForKeyPath:@"objects"]) {
                SnapPhoto *photo = [[SnapPhoto alloc] initWithDictionary:photos];
                [self.api_photos addObject:photo];
            }
                                        
            // hide the load more button if there are no photos
            if (self.api_photos.count <= 0) {
                self.uiLoadMore.hidden = YES;
                self.uiNoPhotos.hidden = NO;
            }
            // there is a photo
            else {
                // display the first 5 photos
                [self loadMoreImages:5];
                                            
                // scroll to first photo if there is at least one row
                //if ([self.tableView numberOfRowsInSection:0] > 0) {
                //    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                //    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                //}
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error fetching photos!");
            DLog(@"%@", error);
        }
     ];
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
}

#pragma mark - Camera delegate
// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    DLog(@"dismiss the imagePicker");
    [picker dismissModalViewControllerAnimated:YES];

    NSInteger event_id = [SnapApiClient getIdFromResourceUri:self.event.resource_uri];
    NSString *request_string = [NSString stringWithFormat:@"photo/?event=%d", event_id];
    
    // some variables to store data in
    NSMutableArray *tempPhotoArray = [NSMutableArray array];
    [[SnapApiClient sharedInstance] getPath:request_string parameters:nil
        success:^(AFHTTPRequestOperation *operation, id response) {
            DLog(@"we got an API response");
            // hydrate the response into objects
            for (id photos in [response valueForKeyPath:@"objects"]) {
                SnapPhoto *photo = [[SnapPhoto alloc] initWithDictionary:photos];
                [tempPhotoArray addObject:photo];
            }
            
            // there already are photos
            // figure out how many are new and add them to the api array
            if (self.api_photos.count > 0) {
                DLog(@"we already have some photos");
                // get the current first API photo and it's id
                SnapPhoto *firstPhoto = [self.api_photos objectAtIndex:0];
                NSInteger firstPhotoId = [SnapApiClient getIdFromResourceUri:firstPhoto.resource_uri];
                
                DLog(@"loop through and merge");
                // get the new photos
                NSMutableArray *newApiPhotoArray = [NSMutableArray array];
                NSMutableArray *mergedApiPhotoArray = [NSMutableArray array];
                NSMutableArray *mergedPhotoArray = [NSMutableArray array];
                SnapPhoto *tempPhoto;
                int i = 0;
                int j = 0;
                while (i < self.photos.count) {
                    // get the new photo
                    tempPhoto = [tempPhotoArray objectAtIndex:j];
                    int tempPhotoId = [SnapApiClient getIdFromResourceUri:tempPhoto.resource_uri];
                    
                    // if the temp photo isn't in the API array
                    if (tempPhotoId > firstPhotoId) {
                        [newApiPhotoArray addObject:tempPhoto];
                        [mergedApiPhotoArray addObject:tempPhoto];
                        [mergedPhotoArray addObject:tempPhoto];
                    }
                    // add the existing photo
                    else {
                        [mergedApiPhotoArray addObject:tempPhoto];
                        [mergedPhotoArray addObject:tempPhoto];
                        i++;
                    }
                    j++;
                }

                // set the api photo array as the merges one
                self.api_photos = mergedApiPhotoArray;
                self.photos = mergedPhotoArray;
                
                DLog(@"about to update the viewTable");
                NSMutableArray *paths = [NSMutableArray arrayWithCapacity:newApiPhotoArray.count];
                for (int i=0; i<newApiPhotoArray.count; i++) {
                    [paths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
            }
            // there are no photos
            else {
                self.api_photos = tempPhotoArray;
                [self loadMoreImages:5];
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error fetching photos!");
            DLog(@"%@", error);
        }
     ];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {

    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;

    // Handle a still image capture
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {

        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];

        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }

        // Save the new image (original or edited) to the Camera Roll
        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        
        // start the share screen
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        SnapPhotoShareViewController *snapPhotoVC = (SnapPhotoShareViewController *)[storyboard instantiateViewControllerWithIdentifier:@"photoShareController"];
        snapPhotoVC.event = self.event;
        snapPhotoVC.photoImage = imageToSave;
        [picker presentViewController:snapPhotoVC animated:YES completion:nil];
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
        }
    }
}

@end
