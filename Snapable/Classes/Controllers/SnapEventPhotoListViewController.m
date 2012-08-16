//
//  SnapEventPhotoListViewController.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-13.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapEventPhotoListViewController.h"
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
@synthesize tableView;

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
    self.tableView.tableHeaderView = header;

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
                NSInteger count = 5;
                [self loadMoreImages:&count];
                
                // scroll to first photo if there is at least one row
                if ([self.tableView numberOfRowsInSection:0] > 0) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"Error fetching photos!");
            DLog(@"%@", error);
        }
     ];
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
    cell.uiPhotoAuthor.text = photo.author_name;
    
    // set the image string
    NSString *photoAbsolutePath = [NSString stringWithFormat:@"%@%@", [SnapAPIBaseURL substringToIndex:(SnapAPIBaseURL.length - 1)], photo.resource_uri];
    
    // set the image to be auto loaded
    [cell.uiPhoto setImageWithURL:[NSURL URLWithString:photoAbsolutePath] placeholderImage:[UIImage imageNamed:@"photoDefault.jpg"]];
    
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
    NSInteger count = 10;
    [self loadMoreImages:&count];
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
    [picker dismissModalViewControllerAnimated:YES];
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
    
        // parameters
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
         event.resource_uri, @"event",
         @"/private_v1/guest/2/", @"guest", // TODO make this not manual or required...
         event.type, @"type",
         nil];
        
        // upload the image
        SnapApiClient *httpClient = [SnapApiClient sharedInstance];
        NSData *imageData = UIImageJPEGRepresentation(imageToSave, 0.5);
        NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"photo/" parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
            [formData appendPartWithFileData:imageData name:@"image" fileName:@"img" mimeType:@"image/jpeg"];
        }];
        
        // sign the request
        request = [httpClient signRequest:request];

        // setup the upload
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setUploadProgressBlock:^(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        }];
        // upload the image
        [operation start];
    }
    
    // close the photo taking screen
    [picker dismissModalViewControllerAnimated:YES];
    
    // TODO reload images
}


#pragma mark - UI Manipulation
- (void)loadMoreImages:(NSInteger *)count {
    // load more images
    if (self.api_photos.count > 0) {
        NSInteger limit = ((self.api_photos.count - self.photos.count) <= abs(*count)) ? (self.api_photos.count - self.photos.count):abs(*count);
        for (int i=0; i<limit; i++) {
            NSInteger nextIndex = self.photos.count;
            [self.photos addObject:[self.api_photos objectAtIndex:nextIndex]];
            NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:nextIndex inSection:0]];
            [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
        }
        
        // hide the load more button if we can't display any more
        if (self.api_photos.count == self.photos.count) {
            self.uiLoadMore.hidden = YES;
        }
    }
}

@end
