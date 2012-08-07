//
//  SnapCameraController.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-02.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapCameraController.h"
#import "SnapCamera.h"

@interface SnapCameraController ()

@end

@implementation SnapCameraController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Camera

- (IBAction) takePicture: (UIButton*) sender
{
    // launch the camera
    SnapCamera *camera = [SnapCamera sharedInstance];
    [camera startCameraControllerFromViewController:self usingDelegate:camera];
}

@end
