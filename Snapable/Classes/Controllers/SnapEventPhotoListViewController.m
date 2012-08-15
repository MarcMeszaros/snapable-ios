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

    // hide the load more button if there are no photos
    if (self.event.photo_count <= 0) {
        self.uiLoadMore.hidden = YES;
        self.uiNoPhotos.hidden = NO;
    }

    // get the event photos, if they haven't been loaded yet
    if (self.api_photos.count <= 0) {
        NSInteger event_id = [SnapApiClient getIdFromResourceUri:self.event.resource_uri];
        NSString *request_string = [NSString stringWithFormat:@"photo/?event=%d", event_id];
        
        [[SnapApiClient sharedInstance] getPath:request_string parameters:nil
            success:^(AFHTTPRequestOperation *operation, id response) {
                // hydrate the response into objects
                for (id photos in [response valueForKeyPath:@"objects"]) {
                    SnapPhoto *photo = [[SnapPhoto alloc] initWithDictionary:photos];
                    [self.api_photos addObject:photo];
                }

                // display the first 5 photos
                if (self.api_photos.count > 0) {
                    NSInteger limit = (self.api_photos.count <= 5) ? (self.api_photos.count):5;
                    for (int i=0; i<limit; i++) {
                        NSInteger nextIndex = self.photos.count;
                        [self.photos addObject:[self.api_photos objectAtIndex:nextIndex]];
                        NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:nextIndex inSection:0]];
                        [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
                    }
                }
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DLog(@"Error fetching photos!");
                DLog(@"%@", error);
            }
         ];
    }
    
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
    [cell.uiPhoto setImageWithURL:[NSURL URLWithString:photoAbsolutePath] placeholderImage:[UIImage imageNamed:@"FPOeventPhoto.jpg"]];
    
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
    // TODO load more photos
    DLog(@"load more button press");
}

- (IBAction) takePhoto: (UIButton*) sender
{
    // launch the camera
    [self.camera startCameraControllerFromViewController:self usingDelegate:self.camera];
}

#pragma mark - Camera delegate
// TODO camera delegate code here


#pragma mark - UI Manipulation
- (void)loadMoreImages:(NSInteger*)count {
    // TODO implementent loading more images
}

@end
