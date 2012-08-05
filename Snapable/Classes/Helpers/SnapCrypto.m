//
//  SnapCrypto.m
//  Snapable
//
//  Created by Marc Meszaros on 12-08-05.
//  Copyright (c) 2012 Snapable. All rights reserved.
//

#import "SnapCrypto.h"

#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

/**
 based on: 
 http://stackoverflow.com/questions/756492/objective-c-sample-code-for-hmac-sha1
 http://stackoverflow.com/questions/690246/sha1-hashes-not-matching-between-my-rails-and-cocoa-apps
 */
@implementation SnapCrypto

+ (NSString*)rawSignatureHMACSHA1:(NSString*)raw_signature apiSecret:(NSString*)secret {

    // parse the string data into NSData objects
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [raw_signature dataUsingEncoding:NSUTF8StringEncoding];
    
    // do the actual hashing and store the result
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
    
    // convert the unsigned char array back into a data object
    NSData* hashResult = [NSData dataWithBytes:result length:CC_SHA1_DIGEST_LENGTH];
    
    // return the data in a hexidecimal string
    return [hashResult hexadecimalString];
}

@end

// from http://stackoverflow.com/questions/1305225/best-way-to-serialize-a-nsdata-into-an-hexadeximal-string
@implementation NSData (NSData_Conversion)

#pragma mark - String Conversion
- (NSString *)hexadecimalString {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

@end