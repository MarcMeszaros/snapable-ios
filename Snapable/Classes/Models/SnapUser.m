//
//  SnapUserModel.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-03.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapUser.h"

@implementation SnapUser

@synthesize email;
@synthesize first_name;
@synthesize last_name;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.email = [dictionary objectForKey:@"email"];
        self.first_name = [dictionary objectForKey:@"first_name"];
        self.last_name = [dictionary objectForKey:@"last_name"];
    }

    return self;
}

@end
