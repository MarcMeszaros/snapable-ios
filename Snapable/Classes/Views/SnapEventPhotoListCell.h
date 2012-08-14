//
//  SnapEventPhotoListCell.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-14.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnapEventPhotoListCell : UITableViewCell {
    IBOutlet UIImageView *uiPhoto;
    IBOutlet UILabel *uiPhotoCaption;
    IBOutlet UILabel *uiPhotoAuthor;
}

@property (nonatomic, strong) UIImageView *uiPhoto;
@property (nonatomic, strong) UILabel *uiPhotoCaption;
@property (nonatomic, strong) UILabel *uiPhotoAuthor;


@end
