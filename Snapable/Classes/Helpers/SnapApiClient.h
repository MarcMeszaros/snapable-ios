//
//  SnapApiClient.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-04.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "AFHTTPClient.h"

@interface SnapApiClient : AFHTTPClient

+ (id)sharedInstance;

@end
