//
//  AppDelegate.h
//  Snapable
//
//  Created by Marc Meszaros on 12-07-30.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@interface SnapAppDelegate : UIResponder <UIApplicationDelegate> {
    FMDatabase *database;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) FMDatabase *database;

@end
