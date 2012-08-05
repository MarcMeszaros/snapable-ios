//
//  SnapApiClient.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-04.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

// define some API constants
#define SnapAPIBaseURLString @"http://devapi.snapable.com/private_v1/"
#define SnapAPIToken @"abc123"

#import "AFJSONRequestOperation.h"
#import "SnapApiClient.h"

@implementation SnapApiClient

+ (id)sharedInstance {
    static SnapApiClient *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SnapApiClient alloc] initWithBaseURL:[NSURL URLWithString:SnapAPIBaseURLString]];
    });
    
    return _sharedInstance;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        //custom settings
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    }
    
    return self;
}

@end
