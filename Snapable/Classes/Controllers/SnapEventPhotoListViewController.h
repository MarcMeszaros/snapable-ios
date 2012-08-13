//
//  SnapEventPhotoListViewController.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-13.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SnapEvent.h"

@interface SnapEventPhotoListViewController : UITableViewController {
    SnapEvent *event;
}

@property (nonatomic, strong) SnapEvent *event;

@end
