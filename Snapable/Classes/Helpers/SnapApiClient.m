//
//  SnapApiClient.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-04.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "AFJSONRequestOperation.h"
#import "SnapApiClient.h"

#import "SnapCrypto.h"

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

// small helper function to return the resource id in a string
+ (NSInteger)getIdFromResourceUri:(NSString *)uri {
    NSArray *parts = [uri componentsSeparatedByString:@"/"];
    return [[parts objectAtIndex:(parts.count - 2)] integerValue];
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        //custom settings
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setParameterEncoding:AFJSONParameterEncoding];
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    }
    
    return self;
}

// sign the request with the Snapable signature requirements
- (NSMutableURLRequest *)signRequest:(NSMutableURLRequest *)request {

    // TODO generate a pseudo-random nonce
    NSString *nonce = @"asd23eas";
    // add the nonce to the header
    [request setValue:nonce forHTTPHeaderField:@"x-SNAP-nonce"];
    
    // get the date
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
    NSString *dateString = [dateFormatter stringFromDate:now];
    // add the date to the header
    [request setValue:dateString forHTTPHeaderField:@"x-SNAP-Date"];
    
    // get the correct signature path
    NSRange endRange = [request.URL.absoluteString rangeOfString:@"?"];
    NSString *sign_path;
    if (endRange.length > 0) {
        NSRange substringRange = NSMakeRange(SnapAPIBaseURL.length-1, endRange.location-(SnapAPIBaseURL.length-1));
        sign_path = [request.URL.absoluteString substringWithRange:substringRange];
    } else {
        sign_path = [request.URL.absoluteString substringFromIndex:(SnapAPIBaseURL.length-1)];
    }
    
    // raw_signature = key + verb + path + nonce + date
    NSString *raw_signature = [NSString stringWithFormat:@"%@%@%@%@%@", SnapAPIKey, request.HTTPMethod, sign_path, nonce, dateString];
    
    // generate the hashed signature
    NSString *hash_signature = [SnapCrypto rawSignatureHMACSHA1:raw_signature apiSecret:SnapAPISecret];
    
    // set the authorization header
    [request setValue:[NSString stringWithFormat:@"SNAP %@:%@", SnapAPIKey, hash_signature] forHTTPHeaderField:@"Authorization"];
    
    return request;
}

// sign all request methods
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {

    // build the request normally in the parent class
    NSMutableURLRequest* request = [super requestWithMethod:method path:path parameters:parameters];
    
    return [self signRequest:request];
}

@end

#pragma mark - UIImage Snapable override

@implementation UIImageView (Snapable)

// override the AFNetworking image loading to sign the request
// SUGGESTION: create a fork/patch for a new method that takes a request instead of a URL
// (ie. then you can sign the request before passing it to AFNetworking)
//
// ex: - (void)setImageWithRequest:(NSMutableURLRequest *)request placeholderImage:(UIImage *)placeholderImage;
//
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPShouldUsePipelining:YES];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self setImageWithURLRequest:[[SnapApiClient sharedInstance] signRequest:request] placeholderImage:placeholderImage success:nil failure:nil];
}

@end
