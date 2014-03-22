//
//  SnapEventListViewController.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-12.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SnapCL.h"
#import "SnapEvent.h"

@interface SnapEventListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SnapCLControllerDelegate>

@property (nonatomic, strong) SnapCL *locationController;

@property (nonatomic, retain) NSMutableArray *events;
@property (nonatomic, strong) SnapEvent *lastSelectedEvent;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *uiNoEventViewGroup;
@property (nonatomic, strong) IBOutlet UISearchBar *uiSearchBar;
@property (nonatomic, strong) IBOutlet UIRefreshControl *refreshControl;

- (void)searchForEventsWithQuery:(NSString *)query;
- (void)refresh:(UIRefreshControl *)sender;

@end
