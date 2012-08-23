//
//  SnapEventListViewController.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-12.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SnapEvent.h"

@interface SnapEventListViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
    NSArray *events;
}

@property (nonatomic, retain) NSArray *events;

@end
