//
//  Analytics.h
//  Snapable
//
//  Created by Marc Meszaros on 10/27/2013.
//  Copyright (c) 2013 Snapable. All rights reserved.
//

#import <Foundation/Foundation.h>

// google analytics
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAILogger.h"

#pragma mark - Enums
typedef NS_ENUM(NSInteger, AnalyticsCategory) {
    AnalyticsCategoryUIAction
};

typedef NS_ENUM(NSInteger, AnalyticsAction) {
    AnalyticsActionButtonPress
};

@interface Analytics : NSObject

#pragma mark - Functions

/**
 Send the screen name as being shown.
 
 @param screenName the screen name to be logged
 */
+ (void)sendScreenName:(NSString *)screenName;

/**
 Send an event to the analytics backend with the specified parameters.
 
 @param category the category for the event (ie. "ui_action")
 @param action the event action (ie. "button_press")
 @param label (optional) the event label (ie. "play")
 @param value (optional) the event value (ie. 1)
 */
+ (void)sendEventWithCategory:(AnalyticsCategory)category action:(AnalyticsAction)action label:(NSString *)label value:(NSNumber *)value;

@end
