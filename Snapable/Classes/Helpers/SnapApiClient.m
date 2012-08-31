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

#pragma mark - Static Functions
+ (id)sharedInstance {
    static SnapApiClient *_sharedInstance;
    static dispatch_once_t onceToken;
    NSString* snapAPIBaseURLString = [NSString stringWithFormat:@"%@%@/", SnapAPIBaseURL, SnapAPIVersion];
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SnapApiClient alloc] initWithBaseURL:[NSURL URLWithString:snapAPIBaseURLString]];
    });
    
    return _sharedInstance;
}

// DEPRECATED
+ (NSInteger)getIdFromResourceUri:(NSString *)uri {
    return [self getIdAsIntegerFromResourceUri:uri];
}

// small helper function to return the resource id in a string
+ (NSInteger)getIdAsIntegerFromResourceUri:(NSString *)uri {
    NSArray *parts = [uri componentsSeparatedByString:@"/"];
    return [[parts objectAtIndex:(parts.count - 2)] integerValue];
}

// small helper function to return the resource id in a string
+ (NSString *)getIdAsStringFromResourceUri:(NSString *)uri {
    NSArray *parts = [uri componentsSeparatedByString:@"/"];
    return [parts objectAtIndex:(parts.count - 2)];
}

// small helper function to set the resource id
+ (NSString *)setIdForResourceUri:(NSString *)uri withString:(NSString *)string {
    NSArray *parts = [uri componentsSeparatedByString:@"/"];
    NSMutableArray *mutableParts = [uri mutableCopy];
    [mutableParts replaceObjectAtIndex:(parts.count - 2) withObject:string];
    return [mutableParts componentsJoinedByString:@""];
}

// small helper function to set the resource id
+ (NSString *)setIdForResourceUri:(NSString *)uri withInteger:(NSInteger)integer {
    NSArray *parts = [uri componentsSeparatedByString:@"/"];
    NSMutableArray *mutableParts = [uri mutableCopy];
    [mutableParts replaceObjectAtIndex:(parts.count - 2) withObject:[NSString stringWithFormat:@"%d", integer]];
    return [mutableParts componentsJoinedByString:@""];
}

#pragma mark - Class Functions
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
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPShouldUsePipelining:YES];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self setImageWithURLRequest:[[SnapApiClient sharedInstance] signRequest:request] placeholderImage:placeholderImage success:nil failure:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure {

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPShouldUsePipelining:YES];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self setImageWithURLRequest:[[SnapApiClient sharedInstance] signRequest:request] placeholderImage:placeholderImage success:success failure:failure];
}

@end
