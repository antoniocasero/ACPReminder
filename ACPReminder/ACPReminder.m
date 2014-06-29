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



static NSString *const kACPLocalNotificationDomain = @"com.company.ACPReminder";
static NSString *const kACPLocalNotificationApp = @"ACPLocalNotificationApp";
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

# pragma mark -
# pragma mark Life cycle
# pragma mark -


- (id)init
{
    self = [super init];
    if (self) {
        //By default
        self.randomMessage = NO;
        self.testFlagInSeconds = NO;
        self.circularTimePeriod = NO;
        self.appDomain = kACPLocalNotificationDomain;
    }
    
    return self;
}




# pragma mark -
# pragma mark Reminder Notification methods
# pragma mark -


- (void) createLocalNotification {
    
    if(!self.messages) {
        ACPLog(@"WARNING: You dont have any message defined!");
        return;
    }
    
    [self cancelThisKindOfNotification:kACPLocalNotificationApp];
    
    NSNumber* timePeriodIndex = [self getTimePeriodIndex];
    NSNumber* periodValue = [self getTimePeriodValue:(NSUInteger)[timePeriodIndex integerValue]];
    NSUInteger messageIndex = [self getMessageIndex];
    NSString * message = self.messages[messageIndex];
    
    NSDate *dateToFire = (self.testFlagInSeconds)?[self dateByAddingSeconds:[periodValue integerValue]]:[self dateByAddingDays:[periodValue integerValue]];
    
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.fireDate = dateToFire;
    localNotification.alertBody = message;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1; // increment
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:timePeriodIndex, kACPNotificationPeriodIndex, kACPLocalNotificationApp, self.appDomain, nil];
    localNotification.userInfo = infoDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [[NSUserDefaults standardUserDefaults] setObject:timePeriodIndex forKey:kACPLastNotificationFired];
    [[NSUserDefaults standardUserDefaults] synchronize];
    ACPLog(@"Local notification scheduled \n Message: %@", message);
    
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
    
    if(!self.timePeriods) {
        ACPLog(@"WARNING: You dont have any time period defined!");
        return nil;
    }
    
    NSNumber* periodIndex = [[NSUserDefaults standardUserDefaults] objectForKey:kACPLastNotificationFired];
    if (periodIndex && (NSUInteger)[periodIndex integerValue] < [self.timePeriods count]){
        periodIndex =[[NSUserDefaults standardUserDefaults] objectForKey:kACPLastNotificationFired];
    }
    else {
        
        periodIndex = nil;
    }
    
    return periodIndex;
    
    
}

- (NSNumber*)getTimePeriodValue:(NSUInteger)index {
    
    
    if(self.timePeriods.count == 0 || index > [self.timePeriods count]) {
        ACPLog(@"WARNING: You dont have any period of time defined. Returning default value.");
        return @(1);
    }
    
    return self.timePeriods[index];
    
    
}

- (void)changeNotificationTimePeriod:(NSInteger)lastNotification {
    
    
    NSInteger newNotification;
    if(self.circularTimePeriod)
        newNotification= (lastNotification +1 >= (NSInteger)[self.timePeriods count]) ? 0 : lastNotification + 1;
    else
        newNotification= (lastNotification +1 >= (NSInteger)[self.timePeriods count]) ? lastNotification : lastNotification + 1;
    
    ACPLog(@"Notification time period has changed from %d to %d", lastNotification, newNotification);
    
    [[NSUserDefaults standardUserDefaults] setObject:@(newNotification) forKey:kACPLastNotificationFired];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


- (BOOL)checkIfReminderNotificationIsScheduled {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    for (UILocalNotification * oneEvent in eventArray)
    {
        NSDictionary *userInfoCurrent = oneEvent.userInfo;
        NSString *type=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:self.appDomain]];
        if ([type isEqualToString:kACPLocalNotificationApp])
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



# pragma mark -
# pragma mark Check if the notification has been triggered
# pragma mark -


- (void)checkIfLocalNotificationHasBeenTriggered {
    
    //1-. Check the latest notification scheduled
    NSNumber* localNotificationType = [[NSUserDefaults standardUserDefaults] objectForKey:kACPLastNotificationFired];
    //2-. If is not nil, we have two options, it has been trigger or its already in schedule.
    if(![self checkIfReminderNotificationIsScheduled]){
        //3-. The notification has been trigger, we need to change the period of time.
        [self changeNotificationTimePeriod:[localNotificationType integerValue]];
        
    }
    
}

# pragma mark -
# pragma mark Methods to cancel types of notifications
# pragma mark -


- (void) cancelThisKindOfNotification:(NSString*)notificationType {
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    for (UILocalNotification * oneEvent in eventArray)
    {
        NSDictionary *userInfoCurrent = oneEvent.userInfo;
        NSString *type=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:self.appDomain]];
        if ([type isEqualToString:kACPLocalNotificationApp] && [notificationType isEqualToString:kACPLocalNotificationApp])
        {
            //Cancelling local notification
            [app cancelLocalNotification:oneEvent];
            ACPLog( @"Previous local notification has been cancelled");
        }
        
    }
}

# pragma mark -
# pragma mark Date handler methods
# pragma mark -

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

- (void) setTestFlagInSeconds:(BOOL)testFlagInSeconds {

#if !DEBUG
    
    NSLog(@"WARNING: TestFlag attribute is YES");
    
#endif
    
    _testFlagInSeconds = testFlagInSeconds;
}


@end
