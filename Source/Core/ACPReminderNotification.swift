//
//  ACPReminderNotification.swift
//  ACPReminder
//
//  Created by Palmero, Antonio on 27/06/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//
import UserNotifications

public struct ACPReminderNotification {

    public typealias Completion = () -> Void
    public var title: String
    public var message: String
    public var attachment: [URL] = []
    public var sound = UNNotificationSound.default()
    public var action: Completion?

    public init(title: String, message: String, attachment: [URL] = [], sound: UNNotificationSound = UNNotificationSound.default(), action: Completion? = nil) {
        self.title = title
        self.message = message
        self.attachment = attachment
        self.sound = sound
        self.action = action
    }
}

public struct ACPReminderConfiguration {

    public var debug: Bool = false
    //If the flag is YES, the message will be selected from the array randomly, if NO sequentially
    public var randomMessage: Bool = false
    //The array of time periods is sequential, if the falg is set to YES when the last element is taken, the next one will be the first element.
    public var circularTimePeriod: Bool = false
    // This attribute define the domain of your notifications, prevent collisions between notifications with other applications using the same library.
    public var appDomain: String
    //Array of strings, contains the messages that you want to present as local notifications.
    public var messages: [ACPReminderNotification] = []
    //Array of time periods between the one local notification presented and the next one.
    public var timePeriods: [Int] = []
    //This flag is available only for test purpose, in case you enable it, the time interval from the array timePeriods will be seconds instead of days.
    public var testFlagSeconds: Bool = false
    //Logs
    public var verbose: Bool = true
    //Flag to define if we want the notifications to be schedule at the same time, or one by one.
    public var oneByOne: Bool = true

    public init(domain: String, messages: [ACPReminderNotification], timePeriods: [Int]) {
        self.messages = messages
        self.appDomain = domain
        self.timePeriods = timePeriods
    }
}
