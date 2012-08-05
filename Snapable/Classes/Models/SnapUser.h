//
//  SnapUserModel.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-03.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnapUser : NSObject {
    BOOL terms;
    NSString *email;
    NSString *first_name;
    NSString *last_name;
    NSString *billing_zip;
    NSString *password_algorithm;
    NSString *password_iterations;
    NSString *password_salt;
    NSString *resource_uri;
}

@property (assign, nonatomic) BOOL terms;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *first_name;
@property (copy, nonatomic) NSString *last_name;
@property (copy, nonatomic) NSString *billing_zip;
@property (copy, nonatomic) NSString *password_algorithm;
@property (copy, nonatomic) NSString *password_iterations;
@property (copy, nonatomic) NSString *password_salt;
@property (copy, nonatomic) NSString *resource_uri;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
