//
//  SnapNavigationBar.m
//  Snapable
//
//  Created by Andrew Draper on 8/2/12.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapNavigationBar.h"

@implementation SnapNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIImage *image = [UIImage imageNamed:@"navigationBarBackgroundImage.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.tintColor = [UIColor colorWithRed:119/255.0 green:186/255.0 blue:220/255.0 alpha:1.0];
}


@end
