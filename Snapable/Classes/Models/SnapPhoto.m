//
//  SnapPhoto.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-05.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapPhoto.h"

@implementation SnapPhoto

@synthesize caption;
@synthesize author_name;
@synthesize timestamp;
@synthesize event;
@synthesize guest;
@synthesize resource_uri;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.steamable = [[dictionary objectForKey:@"enabled"] boolValue];
        self.caption = [dictionary objectForKey:@"caption"];
        self.author_name = [dictionary objectForKey:@"author_name"];
        self.timestamp = [dictionary objectForKey:@"timestamp"];
        self.event = [dictionary objectForKey:@"event"];
        self.guest = [dictionary objectForKey:@"guest"];
        self.resource_uri = [dictionary objectForKey:@"resource_uri"];
    }
    
    return self;
}

@end
