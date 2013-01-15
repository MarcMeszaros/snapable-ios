//
//  SnapEvent.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-05.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnapEvent : NSObject {
    BOOL _enabled;
    int _photo_count;
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

@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL public;
@property (nonatomic) int photo_count;
@property (nonatomic, copy) NSString *start;
@property (nonatomic, copy) NSString *end;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *pin;
@property (nonatomic, copy) NSString *creation_date;
@property (nonatomic, copy) NSString *package;
@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *resource_uri;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
