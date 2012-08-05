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
@synthesize billing_zip;
@synthesize password_algorithm;
@synthesize password_iterations;
@synthesize password_salt;
@synthesize resource_uri;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.terms = [[dictionary objectForKey:@"terms"] boolValue];
        self.email = [dictionary objectForKey:@"email"];
        self.first_name = [dictionary objectForKey:@"first_name"];
        self.last_name = [dictionary objectForKey:@"last_name"];
        self.billing_zip = [dictionary objectForKey:@"billing_zip"];
        self.password_algorithm = [dictionary objectForKey:@"password_algorithm"];
        self.password_iterations = [dictionary objectForKey:@"password_iterations"];
        self.password_salt = [dictionary objectForKey:@"password_salt"];
        self.resource_uri = [dictionary objectForKey:@"resource_uri"];
    }

    return self;
}

@end
