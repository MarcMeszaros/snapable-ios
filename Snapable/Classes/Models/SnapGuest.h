//
//  SnapGuest.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-15.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnapGuest : NSObject {
    NSString *email;
    NSString *name;
    NSString *resource_uri;
}

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *resource_uri;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
