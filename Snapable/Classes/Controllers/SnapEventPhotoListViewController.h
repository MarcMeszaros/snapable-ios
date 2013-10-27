//
//  SnapEventPhotoListViewController.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-13.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SnapApiClient.h"
#import "SnapCamera.h"
#import "SnapEvent.h"
#import "SnapPhoto.h"

@interface SnapEventPhotoListViewController : GAITrackedViewController <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) SnapEvent *event;
@property (nonatomic, strong) SnapCamera *camera;
@property (nonatomic, strong) NSMutableArray *api_photos;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) IBOutlet UIView *uiNoPhotos;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIRefreshControl *refreshControl;

- (void)refresh:(UIRefreshControl *)sender;

@end
