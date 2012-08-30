//
//  AppDelegate.m
//  Snapable
//
//  Created by Marc Meszaros on 12-07-30.
//  Copyright (c) 2012 Snapable. All rights reserved.
//


#import "SnapAppDelegate.h"

@implementation SnapAppDelegate

@synthesize database;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // setup TestFlight key
    [TestFlight takeOff:@"121ded9a748e09c3647168b72ee14e48_MTIyMDUzMjAxMi0wOC0xNiAxMzoyNjowMi44Nzk2MTQ"];
    
    // setup the sqlite database
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"snapable.sqlite"];
    
    DLog(@"database path: %@", path);
    self.database = [FMDatabase databaseWithPath:path];
    [self.database open];
    #ifdef DEBUG
        // when in debug, compile this in so it drops the table when starting app (easier to test)
        [self.database executeUpdate:@"DROP TABLE IF EXISTS event_credentials"];
    #endif
    [self.database executeUpdate:@"CREATE TABLE IF NOT EXISTS event_credentials(id INT PRIMARY KEY, guest_id INT, email TEXT, name TEXT, pin TEXT)"];
    [self.database close];
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
