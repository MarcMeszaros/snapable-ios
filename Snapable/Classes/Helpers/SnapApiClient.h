//
//  SnapApiClient.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-04.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "AFHTTPClient.h"
#import "UIImageView+AFNetworking.h"

// define some API constants
#define SnapAPIBaseURL @"https://devapi.snapable.com/"
#define SnapAPIVersion @"private_v1"
#define SnapAPIKey @"abc123"
#define SnapAPISecret @"123"

@interface SnapApiClient : AFHTTPClient

+ (id)sharedInstance;
+ (NSInteger)getIdFromResourceUri:(NSString *)uri __attribute__((deprecated("use method 'getIdAsIntegerFromResourceUri' instead")));
+ (NSString *)getIdAsStringFromResourceUri:(NSString *)uri;
+ (NSInteger)getIdAsIntegerFromResourceUri:(NSString *)uri;
+ (NSString *)setIdForResourceUri:(NSString *)uri withString:(NSString *)string;
+ (NSString *)setIdForResourceUri:(NSString *)uri withInteger:(NSInteger)integer;

- (NSMutableURLRequest *)signRequest:(NSMutableURLRequest *)request;

@end

@interface UIImageView (Snapable)

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

@end
