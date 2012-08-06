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
@synthesize metrics;
@synthesize timestamp;
@synthesize event;
@synthesize guest;
@synthesize type;
@synthesize resource_uri;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.steamable = [[dictionary objectForKey:@"enabled"] boolValue];
        self.caption = [dictionary objectForKey:@"caption"];
        self.metrics = [dictionary objectForKey:@"metrics"];
        self.timestamp = [dictionary objectForKey:@"timestamp"];
        self.event = [dictionary objectForKey:@"event"];
        self.guest = [dictionary objectForKey:@"guest"];
        self.type = [dictionary objectForKey:@"type"];
        self.resource_uri = [dictionary objectForKey:@"resource_uri"];
    }
    
    return self;
}

@end