//
//  SnapEventListViewController.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-09.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapEventListViewController.h"

@interface SnapEventListViewController ()

@end

@implementation SnapEventListViewController

@synthesize event;

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
    NSLog(@"event title: %@", self.event.title);
    eventTitle.text = self.event.title;
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

@end
