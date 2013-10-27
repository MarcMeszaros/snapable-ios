//
//  SnapEventListViewController.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-12.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SnapEvent.h"

@interface SnapEventListViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSArray *events;
@property (nonatomic, strong) SnapEvent *lastSelectedEvent;
@property (nonatomic, strong) UIView *uiNoEventViewGroup;
@property (nonatomic, strong) UISearchBar *uiSearchBar;

- (void)searchForEventsWithQuery:(NSString *)query;

@end
