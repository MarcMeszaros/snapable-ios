//
//  SnapEvent.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-05.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapEvent.h"

@implementation SnapEvent

@synthesize enabled = _enabled;
@synthesize photo_count = _photo_count;
@synthesize tz_offset = _tz_offset;
@synthesize start;
@synthesize end;
@synthesize title;
@synthesize url;
@synthesize pin;
@synthesize public;
@synthesize creation_date;
@synthesize package;
@synthesize user;
@synthesize resource_uri;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.enabled = [[dictionary objectForKey:@"enabled"] boolValue];
        self.photo_count = [[dictionary objectForKey:@"photo_count"] integerValue];
        self.tz_offset = [[dictionary objectForKey:@"tz_offset"] integerValue];
        self.start = [dictionary objectForKey:@"start"];
        self.end = [dictionary objectForKey:@"end"];
        self.title = [dictionary objectForKey:@"title"];
        self.url = [dictionary objectForKey:@"url"];
        self.pin = [dictionary objectForKey:@"pin"];
        self.public = [[dictionary objectForKey:@"public"] boolValue];
        self.creation_date = [dictionary objectForKey:@"creation_date"];
        self.package = [dictionary objectForKey:@"package"];
        self.user = [dictionary objectForKey:@"user"];
        self.resource_uri = [dictionary objectForKey:@"resource_uri"];
    }
    
    return self;
}

@end
