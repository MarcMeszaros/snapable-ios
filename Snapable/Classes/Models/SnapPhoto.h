//
//  SnapPhoto.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-05.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnapPhoto : NSObject {
    BOOL streamable;
    NSString *caption;
    NSString *metrics;
    NSString *timestamp;
    
    NSString *event;
    NSString *guest;
    NSString *type;
    NSString *resource_uri;
}

@property (assign, nonatomic) BOOL steamable;
@property (copy, nonatomic) NSString *caption;
@property (copy, nonatomic) NSString *metrics;
@property (copy, nonatomic) NSString *timestamp;
@property (copy, nonatomic) NSString *event;
@property (copy, nonatomic) NSString *guest;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *resource_uri;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
