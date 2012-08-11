//
//  SnapEventListViewController.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-09.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SnapEvent.h"

@interface SnapEventListViewController : UIViewController {
    SnapEvent *event;
    IBOutlet UILabel *eventTitle;
}

@property (nonatomic, strong) SnapEvent *event;

@end
