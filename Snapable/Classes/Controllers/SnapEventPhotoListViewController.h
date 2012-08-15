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

@interface SnapEventPhotoListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    SnapEvent *event;
    SnapCamera *camera;
    NSMutableArray *api_photos;
    NSMutableArray *photos;
    IBOutlet UIView *uiNoPhotos;
    IBOutlet UIButton *uiLoadMore;
    IBOutlet UITableView *tableView;
}

@property (nonatomic, strong) SnapEvent *event;
@property (nonatomic, retain) SnapCamera *camera;
@property (nonatomic, retain) NSMutableArray *api_photos;
@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic, retain) UIView *uiNoPhotos;
@property (nonatomic, retain) UIButton *uiLoadMore;
@property (nonatomic, strong) UITableView *tableView;

- (void)loadMoreImages:(NSInteger*)count;

@end
