//
//  SnapApiClient.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-04.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

// define some API constants
#define SnapAPIBaseURL @"http://devapi.snapable.com/"
#define SnapAPIVersion @"private_v1"
#define SnapAPIKey @"abc123"
#define SnapAPISecret @"123"

#include <CommonCrypto/CommonHMAC.h>

#import "AFJSONRequestOperation.h"
#import "SnapApiClient.h"

@implementation SnapApiClient

+ (id)sharedInstance {
    static SnapApiClient *_sharedInstance;
    static dispatch_once_t onceToken;
    NSString* snapAPIBaseURLString = [NSString stringWithFormat:@"%@%@/", SnapAPIBaseURL, SnapAPIVersion];
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SnapApiClient alloc] initWithBaseURL:[NSURL URLWithString:snapAPIBaseURLString]];
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

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {

    // build the request normally in the parent class
    NSMutableURLRequest* request = [super requestWithMethod:method path:path parameters:parameters];

    // TODO generate a nonce
    NSString* nonce = @"asdfiuyasb";
    // add the nonce to the header
    [request setValue:nonce forHTTPHeaderField:@"x-SNAP-nonce"];

    // get the date
    NSDate* now = [[NSDate alloc] init];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
    NSString* dateString = [dateFormatter stringFromDate:now];
    // add the date to the header
    [request setValue:dateString forHTTPHeaderField:@"x-SNAP-Date"];

    // raw_signature = secret + verb + path + nonce + date
    NSString* raw_signature = [NSString stringWithFormat:@"%@%@%@%@%@", SnapAPIKey, request.HTTPMethod, [request.URL.absoluteString substringFromIndex:(SnapAPIBaseURL.length-1)], nonce, dateString];

    // TODO generate the signature
    NSString* hash_signature = raw_signature;

    // set the authorization header
    [request setValue:[NSString stringWithFormat:@"SNAP %@:%@", SnapAPIKey, hash_signature] forHTTPHeaderField:@"Authorization"];

    // print out some data
    NSLog(@"raw_signature: %@", raw_signature);
    NSLog(@"hash_signature: %@", hash_signature);
    NSLog(@"x-snap-nonce: %@", [request valueForHTTPHeaderField:@"x-SNAP-nonce"]);
    NSLog(@"x-snap-date: %@", [request valueForHTTPHeaderField:@"x-SNAP-Date"]);
    NSLog(@"authorization: %@", [request valueForHTTPHeaderField:@"Authorization"]);

    return request;
}

@end
