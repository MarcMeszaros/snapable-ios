//
//  SnapEventPhotoListViewController.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-13.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SnapEvent.h"

@interface SnapEventPhotoListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    SnapEvent *event;
    IBOutlet UIView *uiNoPhotos;
    IBOutlet UIButton *uiLoadMore;
    IBOutlet UITableView *tableView;
}

@property (nonatomic, strong) SnapEvent *event;
@property (nonatomic, retain) UIView *uiNoPhotos;
@property (nonatomic, retain) UIButton *uiLoadMore;
@property (nonatomic, strong) UITableView *tableView;

@end
