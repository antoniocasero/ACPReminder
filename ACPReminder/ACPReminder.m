//
//  ACPReminder.m
//  ACPReminderExample
//
//  Created by Antonio Casero on 27/04/14.
//  Copyright (c) 2014 Uttopia. All rights reserved.
//


#if DEBUG
#define ACPLog( s, ... ) NSLog( @"[%@:%d] %@", [[NSString stringWithUTF8String:__FILE__] \
lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define ACPLog( s, ... )
#endif


#import "ACPReminder.h"

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

#define D_DAY 86400



static NSString *const kACPLocalNotificationDomain = @"com.company.remember.myApp";
static NSString *const kACPLocalNotificationRememberMyApp = @"ACPLocalNotificationRememberMyApp";
static NSString *const kACPLastNotificationFired = @"ACPLastNotificationFired";
static NSString *const kACPNotificationMessageIndex = @"ACPNotificationMessageIndex";
static NSString *const kACPNotificationPeriodIndex = @"kACPNotificationPeriodIndex";


@interface ACPReminder ()
{
    BOOL notificationHasBeenFired;
}

@end

@implementation ACPReminder

+ (id)sharedManager
{
    static ACPReminder *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        
    });
    
    return sharedManager;
}

//----------------------------------------------------------------------------------------------------------------
# pragma mark -
# pragma mark Life cycle
# pragma mark -
//----------------------------------------------------------------------------------------------------------------

- (id)init
{
    self = [super init];
    if (self) {
        //Messages by default
        self.randomMessage = NO;
        self.testFlagInSeconds = NO;
        self.circularTimePeriod = NO;
    }
    
    return self;
}



//----------------------------------------------------------------------------------------------------------------
# pragma mark -
# pragma mark Reminder Notification methods
# pragma mark -
//----------------------------------------------------------------------------------------------------------------

- (void) createLocalNotification {

    if(!self.messages) {
        ACPLog(@"WARNING: You dont have any message defined");
        return;
    }

    [self cancelThisKindOfNotification:kACPLocalNotificationRememberMyApp];

    NSNumber* timePeriodIndex = [self getTimePeriodIndex];
    NSNumber* periodValue = self.timePeriods[(NSUInteger)[timePeriodIndex integerValue]];
    NSUInteger messageIndex = [self getMessageIndex];
    NSString * message = self.messages[messageIndex];

    NSDate *dateToFire = (self.testFlagInSeconds)?[self dateByAddingSeconds:[periodValue integerValue]]:[self dateByAddingDays:[periodValue integerValue]];

    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.fireDate = dateToFire;
    localNotification.alertBody = message;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1; // increment
    
    //The firs object in the Dictionary is th value of the notification reminder type
    //The second one is the type of notification. why? because we will work with two different types, the reminder to use the app and the reminder to download a video who is about to expire.
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:timePeriodIndex, kACPNotificationPeriodIndex, kACPLocalNotificationRememberMyApp, kACPLocalNotificationDomain, nil];
    localNotification.userInfo = infoDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [[NSUserDefaults standardUserDefaults] setObject:timePeriodIndex forKey:kACPLastNotificationFired];
    [[NSUserDefaults standardUserDefaults] synchronize];
     ACPLog(@"Local notification for the use of the app scheduled \n Message: %@", message);
    
    
    
}

- (NSUInteger) getMessageIndex {
    
    if(self.randomMessage) {
        return arc4random()%[self.messages count];
    }
    else {
        NSUserDefaults * configuration = [NSUserDefaults standardUserDefaults];
        NSUInteger notificationIndex;
        if(![configuration objectForKey:kACPNotificationMessageIndex]) {
            notificationIndex = 0;
        } else {
            notificationIndex = (NSUInteger)[[configuration objectForKey:kACPNotificationMessageIndex] integerValue];
            NSUInteger increment  = (notificationHasBeenFired)?0:1;
            notificationIndex = notificationIndex - increment;
            
            if(notificationIndex >= [self.messages count]) {
                notificationIndex = 0;
            }
        }
        [configuration setObject:@(notificationIndex + 1) forKey:kACPNotificationMessageIndex];
        
        return notificationIndex;
        
    }
    
}

- (NSNumber*)getTimePeriodIndex {
    
    NSNumber* periodIndex = [[NSUserDefaults standardUserDefaults] objectForKey:kACPLastNotificationFired];
    if (periodIndex && (NSUInteger)[periodIndex integerValue] < [self.timePeriods count]){
        periodIndex =[[NSUserDefaults standardUserDefaults] objectForKey:kACPLastNotificationFired];
    }
    else {
        
        periodIndex = @([periodIndex integerValue] -1);
    }
    
    return periodIndex;
    
    
}

- (void) changeTheTypeOfReminderNotification:(NSInteger)lastNotification {
    
    
    NSInteger newNotification;
    if(self.circularTimePeriod)
        newNotification= (lastNotification +1 >= (NSInteger)[self.timePeriods count]) ? 0 : lastNotification + 1;
    else
        newNotification= (lastNotification +1 >= (NSInteger)[self.timePeriods count]) ? lastNotification : lastNotification + 1;
    ACPLog(@"Notification time period has changed from %d to %d", lastNotification, newNotification);

    [[NSUserDefaults standardUserDefaults] setObject:@(newNotification) forKey:kACPLastNotificationFired];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}




//----------------------------------------------------------------------------------------------------------------
# pragma mark -
# pragma mark Methods to cancel types of notifications
# pragma mark -
//----------------------------------------------------------------------------------------------------------------

- (void) cancelThisKindOfNotification:(NSString*)notificationType {
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    for (UILocalNotification * oneEvent in eventArray)
    {
        NSDictionary *userInfoCurrent = oneEvent.userInfo;
        NSString *type=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:kACPLocalNotificationDomain]];
        if ([type isEqualToString:kACPLocalNotificationRememberMyApp] && [notificationType isEqualToString:kACPLocalNotificationRememberMyApp])
        {
            //Cancelling local notification
            [app cancelLocalNotification:oneEvent];
            ACPLog( @"The local notification has been cancelled");
        }
                
    }
}
- (BOOL) checkIfTheReminderNotificationIsScheduled {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    for (UILocalNotification * oneEvent in eventArray)
    {
        NSDictionary *userInfoCurrent = oneEvent.userInfo;
        NSString *type=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:kACPLocalNotificationDomain]];
        if ([type isEqualToString:kACPLocalNotificationRememberMyApp])
        {
            ACPLog( @"The local notification has not been triggered");
            notificationHasBeenFired = NO;
            return YES;
        }
        
    }
    ACPLog(@"The local notification has been triggered");
    notificationHasBeenFired = YES;
    return NO;
}


//----------------------------------------------------------------------------------------------------------------
# pragma mark -
# pragma mark Check if the notification has been triggered
# pragma mark -
//----------------------------------------------------------------------------------------------------------------

- (void)checkIfLocalNotificationHasBeenTriggered {
    
    //1-. Check the latest notification scheduled
    NSNumber* localNotificationType = [[NSUserDefaults standardUserDefaults] objectForKey:kACPLastNotificationFired];
    //2-. If is not nil, we have two options, it has been trigger or its already in schedule.
    if(![self checkIfTheReminderNotificationIsScheduled]){
        //3-. The notification has been trigger, so we change the type
        [self changeTheTypeOfReminderNotification:[localNotificationType integerValue]];
        
    }

}

- (NSDate *) dateByAddingDays: (NSInteger) dDays
{
	NSTimeInterval aTimeInterval = [NSDate timeIntervalSinceReferenceDate] + D_DAY * dDays;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

- (NSDate *) dateByAddingSeconds: (NSInteger) dSeconds
{
	NSTimeInterval aTimeInterval = [NSDate timeIntervalSinceReferenceDate] + dSeconds;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}



@end
