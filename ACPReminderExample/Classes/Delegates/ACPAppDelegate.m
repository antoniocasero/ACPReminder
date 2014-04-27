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

    return YES;
}



- (void)applicationDidEnterBackground:(UIApplication *)application
{

    
    ACPReminder * localNotifications = [ACPReminder sharedManager];
    localNotifications.messages = @[@"Example 1", @"Example 2", @"Example 3", @"Example 4", @"Example 5"];
    localNotifications.timePeriods = @[@(1),@(3),@(5)]; //days
    localNotifications.randomMessage = NO; //By default is NO
    localNotifications.testFlagInSeconds = YES; //By default is NO
    localNotifications.circularTimePeriod = NO;
    [localNotifications createLocalNotification];
}



- (void)applicationDidBecomeActive:(UIApplication *)application
{

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[ACPReminder sharedManager] checkIfLocalNotificationHasBeenTriggered];
    
}


@end
