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
+ (NSInteger)getIdFromResourceUri:(NSString *)uri;

- (NSMutableURLRequest *)signRequest:(NSMutableURLRequest *)request;

@end

@interface UIImageView (Snapable)

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage;

@end
