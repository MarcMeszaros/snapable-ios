//
//  SnapGuest.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-15.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapGuest.h"

@implementation SnapGuest

@synthesize email;
@synthesize name;
@synthesize resource_uri;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.email = [dictionary objectForKey:@"email"];
        self.name = [dictionary objectForKey:@"name"];
        self.resource_uri = [dictionary objectForKey:@"resource_uri"];
    }
    
    return self;
}

@end
