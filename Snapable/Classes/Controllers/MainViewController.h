//
//  MainViewController.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-01.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController {
    int apiCount;
}

@property (weak, nonatomic) IBOutlet UILabel *APICount;
@property (weak, nonatomic) IBOutlet UIButton *APIButton;

- (IBAction)apiButtonPressed:(id)sender;

@end
