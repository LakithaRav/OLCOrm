//
//  OLCAppDelegate.m
//  OLCOrm
//
//  Created by CocoaPods on 08/10/2014.
//  Copyright (c) 2014 Lakitha Samarasinghe. All rights reserved.
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#import "OLCAppDelegate.h"
#import "OLCOrm.h"
#import "TestObject.h"
#import "UserObject.h"


@implementation OLCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
//    [Crashlytics startWithAPIKey:@"1f6d052a2d1b10665a77ee75fd6e6d2681450b78"];
    
    //NSLog(@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory  inDomains:NSUserDomainMask] lastObject]);
    
    [self setupTheme];
    [self initDb];
    
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

#pragma OLCOrm Custom Methods

- (void) setupTheme
{
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x5AC8FB)];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void) initDb
{
    OLCOrm *dbH = [OLCOrm databaseName:@"olcdemo.sqlite" version:[NSNumber numberWithInt:24] enableDebug:NO];

    [dbH makeTable:[TestObject class]];
    [dbH makeTable:[UserObject class] withMigration:NO];
}

@end
