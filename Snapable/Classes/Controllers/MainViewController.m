//
//  MainViewController.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-01.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()


@end

@implementation MainViewController
@synthesize APICount;
@synthesize APIButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        apiCount = 0;
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
    [self setAPIButton:nil];
    [self setAPICount:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)apiButtonPressed:(id)sender {
    apiCount++;
    APICount.text = [NSString stringWithFormat:@"%d", apiCount];
    NSLog(@"Click count is now: %d", apiCount);
}
@end
