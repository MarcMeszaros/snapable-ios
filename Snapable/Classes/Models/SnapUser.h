//
//  SnapUserModel.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-03.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnapUser : NSObject

@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *first_name;
@property (copy, nonatomic) NSString *last_name;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
