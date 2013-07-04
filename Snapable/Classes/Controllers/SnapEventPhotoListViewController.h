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

@interface SnapEventPhotoListViewController : GAITrackedViewController <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    SnapEvent *event;
    SnapCamera *camera;
    NSMutableArray *api_photos;
    NSMutableArray *_photos;
    IBOutlet UIView *uiNoPhotos;
    IBOutlet UIButton *uiLoadMore;
    IBOutlet UITableView *_tableView;
}

@property (nonatomic, strong) SnapEvent *event;
@property (nonatomic, strong) SnapCamera *camera;
@property (nonatomic, strong) NSMutableArray *api_photos;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) UIView *uiNoPhotos;
@property (nonatomic, strong) UIButton *uiLoadMore;
@property (nonatomic, strong) UITableView *tableView;

- (void)loadMoreImages:(NSInteger)count;
- (void)refresh;

@end
