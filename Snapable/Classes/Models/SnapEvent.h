//
//  SnapEvent.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-05.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnapEvent : NSObject {
    BOOL enabled;
    int photo_count;
    NSString *start;
    NSString *end;
    NSString *title;
    NSString *url;
    NSString *pin;
    
    NSString *creation_date;
    NSString *package;
    NSString *user;
    NSString *resource_uri;
}

@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) int photo_count;
@property (copy, nonatomic) NSString *start;
@property (copy, nonatomic) NSString *end;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *pin;
@property (copy, nonatomic) NSString *creation_date;
@property (copy, nonatomic) NSString *package;
@property (copy, nonatomic) NSString *user;
@property (copy, nonatomic) NSString *resource_uri;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
