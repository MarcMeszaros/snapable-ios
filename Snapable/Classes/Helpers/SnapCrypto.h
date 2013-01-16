//
//  SnapCrypto.h
//  Snapable
//
//  Created by Marc Meszaros on 12-08-05.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 based on:
 http://stackoverflow.com/questions/756492/objective-c-sample-code-for-hmac-sha1
 http://stackoverflow.com/questions/690246/sha1-hashes-not-matching-between-my-rails-and-cocoa-apps
 */
@interface SnapCrypto : NSObject

+ (NSString*)rawSignatureHMACSHA1:(NSString*)raw_signature apiSecret:(NSString*)secret;
+ (NSString*)randomHexStringWithLength:(NSInteger)length;

@end

// from http://stackoverflow.com/questions/1305225/best-way-to-serialize-a-nsdata-into-an-hexadeximal-string
@interface NSData (NSData_Conversion)

#pragma mark - String Conversion
- (NSString *)hexadecimalString;

@end