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
#ifdef DEBUG
#   define SnapAPIBaseURL @"https://devapi.snapable.com/"
#   define SnapAPIVersion @"private_v1"
#   define SnapAPIKey @"key123"
#   define SnapAPISecret @"sec123"
#else
#   define SnapAPIBaseURL @"https://api.snapable.com/"
#   define SnapAPIVersion @"private_v1"
#   define SnapAPIKey @"9e304d4e8df1b74cfa009913198428ab"
#   define SnapAPISecret @"5230222ab6f0dbd3175c90b327ed2fbf9648b7926aa2f5082e06fe8e5b8313b5"
#endif

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

- (void)setImageWithSignedURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;
- (void)setImageWithSignedURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

@end
