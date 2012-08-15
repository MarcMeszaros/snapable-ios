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
    NSString *author_name;
    NSString *metrics;
    NSString *timestamp;
    
    NSString *event;
    NSString *guest;
    NSString *type;
    NSString *resource_uri;
}

@property (nonatomic) BOOL steamable;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSString *author_name;
@property (nonatomic, copy) NSString *metrics;
@property (nonatomic, copy) NSString *timestamp;
@property (nonatomic, copy) NSString *event;
@property (nonatomic, copy) NSString *guest;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *resource_uri;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
