//
//  ACPReminder.h
//  ACPReminderExample
//
//  Created by Antonio Casero on 27/04/14.
//  Copyright (c) 2014 Uttopia. All rights reserved.
//


#import <Foundation/Foundation.h>


/**
 `Purpose` ACPReminder provides automatic local notificacions, in order to marketing your app or explaining use cases to user. It will schedule automatically some predefined messages when the user closes your application, and it will be trigger some time later if the user doesn't open the app in that period of time. If the notification has been triggered, then it will take another of your predefined messages and scheduled with the next date, defined previously.

 */
@interface ACPReminder : NSObject

/**
 *  If the flag is YES, the message will be selected from the array randomly, if NO sequentially
 *
 *  @note By default, the value is NO
 */
@property (nonatomic, assign) BOOL randomMessage;

/**
 *  The array of time periods is sequential, if the falg is set to YES when the last element is taken, the next one will be the first element. 
 *  Otherwise it will take in the last element.
 *
 *  @note By default, the value is NO
 */
@property (nonatomic, assign) BOOL circularTimePeriod;

/**
 *  This flag is available only for test purpose, in case you enable it, the time interval from the array timePeriods will be seconds instead of days.
 *
 *  @note By default, the value is NOT
 *  @warning It shouldn't be enable in production mode.
 */
@property (nonatomic, assign) BOOL testFlagInSeconds;

+ (instancetype)sharedManager;

/**
 *  Array of strings, contains the messages that you want to present as local notifications.
 *
 *  @note Is highly recommended to use NSLocalizedString, so you can target different countries.
 *
 *  @see NSLocalizedString
 */
@property (nonatomic, strong) NSArray* messages;

/**
 *  Array of time periods between the one local notification presented and the next one.
 *
 *  @note The elements has to be NSNumbers.
 */
@property (nonatomic, strong) NSArray* timePeriods;


/**
 *  Prepares the local notification and it will be schedule.
 *
 *  @note This method should be called when the user is going to close the application usually \c -applicationDidEnterBackground:
 */
- (void) createLocalNotification;

/**
 *  This method is called when the aplication become active (usually  \c -applicationDidBecomeActive:). 
 *  It will check if we have any local notification pending, in that case, it will be cancelled,
 *  If the notification has been triggered, it will prepare the next notification, taking the next message and the next time period.
 *
 *  @see timePeriods and messages
 */
- (void)checkIfLocalNotificationHasBeenTriggered;

@end

