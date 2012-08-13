//
//  SnapEventListCell.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-12.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnapEventListCell : UITableViewCell {
    IBOutlet UIImageView *uiPhoto;
    IBOutlet UILabel *uiEventTitle;
    IBOutlet UILabel *uiEventDate;
}

@property (nonatomic, strong) UIImageView *uiPhoto;
@property (nonatomic, strong) UILabel *uiEventTitle;
@property (nonatomic, strong) UILabel *uiEventDate;

@end
