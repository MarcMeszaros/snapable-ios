//
//  AppDelegate.m
//  Snapable
//
//  Created by Marc Meszaros on 12-07-30.
//  Copyright (c) 2012 Snapable. All rights reserved.
//


#import "SnapAppDelegate.h"

#import "AFNetworking.h"

#import "SnapApiClient.h"
#import "SnapUser.h"

@implementation SnapAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[SnapApiClient sharedInstance] getPath:@"user/" parameters:nil
        success:^(AFHTTPRequestOperation *operation, id response) {
            // hydrate the response into objects
            NSMutableArray* results = [NSMutableArray array];
            for (id userDictionary in [response valueForKeyPath:@"objects"]) {
                SnapUser *user = [[SnapUser alloc] initWithDictionary:userDictionary];
                [results addObject:user];
            }

            // print some values using 2 different object access methods
            SnapUser* item = [results objectAtIndex:0];
            NSLog(@"email: %@", item.email); // using dot notation
            NSLog(@"first_name: %@", item.first_name); // using dot notation
            NSLog(@"last_name: %@", item.last_name); // using dot notation
            NSLog(@"terms: %i", item.terms); // using dot notation
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error fetching users!");
            NSLog(@"%@", error);
        }
     ];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
