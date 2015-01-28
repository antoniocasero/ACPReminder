//
//  ACPAppDelegate.m
//  ACPReminderExample
//
//  Created by Antonio Casero on 4/27/14
//  Copyright (c) 2014 Uttopia. All rights reserved.
//

#import "ACPAppDelegate.h"
#import "ACPReminder.h"


@implementation ACPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // iOS 8 support
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    // Override point for customization after application launch.
    return YES;
}



- (void)applicationDidEnterBackground:(UIApplication *)application
{
    ACPReminder * localNotifications = [ACPReminder sharedManager];
    
    //Settings
    localNotifications.messages = @[@"Example 1", @"Example 2", @"Example 3", @"Example 4", @"Example 5"];
    localNotifications.timePeriods = @[@(1),@(4),@(8),@(10)]; //days
    localNotifications.appDomain = @"com.mydomain.appName";
    localNotifications.randomMessage = NO; //By default is NO (optional)
    localNotifications.testFlagInSeconds = YES; //By default is NO (optional) -->For testing purpose only!
    localNotifications.circularTimePeriod = YES; // By default is NO (optional)

    [localNotifications createLocalNotification];
}



- (void)applicationDidBecomeActive:(UIApplication *)application
{

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[ACPReminder sharedManager] checkIfLocalNotificationHasBeenTriggered];
    
}


@end
