//
//  SnapUserModel.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-03.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnapUser : NSObject {
    BOOL _terms;
    NSString *email;
    NSString *first_name;
    NSString *last_name;
    NSString *billing_zip;
    NSString *password_algorithm;
    NSString *password_iterations;
    NSString *password_salt;
    NSString *resource_uri;
}

@property (nonatomic) BOOL terms;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *first_name;
@property (nonatomic, copy) NSString *last_name;
@property (nonatomic, copy) NSString *billing_zip;
@property (nonatomic, copy) NSString *password_algorithm;
@property (nonatomic, copy) NSString *password_iterations;
@property (nonatomic, copy) NSString *password_salt;
@property (nonatomic, copy) NSString *resource_uri;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
