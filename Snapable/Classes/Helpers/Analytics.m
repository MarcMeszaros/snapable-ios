//
//  Analytics.m
//  Snapable
//
//  Created by Marc Meszaros on 10/27/2013.
//  Copyright (c) 2013 Snapable. All rights reserved.
//

#import "Analytics.h"

@implementation Analytics

+ (void)sendScreenName:(NSString *)screenName
{
    // May return nil if a tracker has not already been initialized with a property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:kGAITrackingId]; // Google Analytics
    if (tracker) {
        [tracker set:kGAIScreenName value:screenName];
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    }
}

+ (void)sendEventWithCategory:(AnalyticsCategory)category action:(AnalyticsAction)action label:(NSString *)label value:(NSNumber *)value
{
    // May return nil if a tracker has not already been initialized with a property ID.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:kGAITrackingId]; // Google Analytics
    if (tracker) {
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[self analyticsCategoryToString:category]  // Event category (required)
                                                              action:[self analyticsActionToString:action]      // Event action (required)
                                                               label:label                                      // Event label
                                                               value:value] build]];                            // Event value
    }
}


#pragma mark - Helper Functions

+ (NSString *)analyticsCategoryToString:(AnalyticsCategory)analyticsCategory
{
    NSString *result = nil;
    
    switch(analyticsCategory) {
        case AnalyticsCategoryUIAction:
            result = @"ui_action";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected AnalyticsCategory."];
    }
    
    return result;
}

+ (NSString *)analyticsActionToString:(AnalyticsAction)analyticsAction
{
    NSString *result = nil;
    
    switch(analyticsAction) {
        case AnalyticsActionButtonPress:
            result = @"button_press";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected AnalyticsAction."];
    }
    
    return result;
}

@end
