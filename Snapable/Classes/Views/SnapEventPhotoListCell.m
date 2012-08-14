//
//  SnapEventPhotoListCell.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-14.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapEventPhotoListCell.h"

@implementation SnapEventPhotoListCell

@synthesize uiPhoto;
@synthesize uiPhotoCaption;
@synthesize uiPhotoAuthor;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
