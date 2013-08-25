//
//  SnapImagePicker.m
//  Snapable
//
//  Created by Marc Meszaros on 2013-08-25.
//  Copyright (c) 2013 Snapable. All rights reserved.
//

#import "SnapImagePicker.h"

@interface SnapImagePicker ()

@end

@implementation SnapImagePicker

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleBlackOpaque;
}

@end
