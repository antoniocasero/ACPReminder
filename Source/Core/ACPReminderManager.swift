//
//  ACPReminder.swift
//  ACPReminder
//
//  Created by Palmero, Antonio on 27/06/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//
import UserNotifications

public class ACPReminderManager {
    public let configuration: ACPReminderConfiguration
    private let userDefaults = UserDefaults.standard
    private let notificationCenter = UNUserNotificationCenter.current()
    private var notifications: [String] = []

    init(configuration: ACPReminderConfiguration) {
        self.configuration = configuration
    }

    private var lastNotification: Int {
        get {
            return userDefaults.integer(forKey: "last")
        }

        set {
            return userDefaults.set(lastNotification, forKey: "last")
        }
    }

    func queue(notification: ACPReminderNotification) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.message
        content.sound = notification.sound
        content.attachments = []
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = "time_interval_\(NSDate())"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            ACPLog("error: \(error)")
        }
    }

}
func ACPLog<T>( _ object: @autoclosure() -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    #if DEBUG
        let fileURL = NSURL(string: file)?.lastPathComponent ?? "Unknown file"
        let queue = Thread.isMainThread ? "UI" : "BG"
        print("<\(queue)> \(fileURL) \(function)[\(line)]: \(object())")
    #endif
}

public protocol ACPReminderConfiguration {
    var debug: Bool { get set }
    //If the flag is YES, the message will be selected from the array randomly, if NO sequentially
    var randomMessage: Bool { get set }
    //The array of time periods is sequential, if the falg is set to YES when the last element is taken, the next one will be the first element.
    var circularTimePeriod: Bool { get set }
    // This attribute define the domain of your notifications, prevent collisions between notifications with other applications using the same library.
    var appDomain: String { get set }
    //Array of strings, contains the messages that you want to present as local notifications.
    var messages: [String] { get set }
    //Array of time periods between the one local notification presented and the next one.
    var timePeriods: [Int] { get set }
    //This flag is available only for test purpose, in case you enable it, the time interval from the array timePeriods will be seconds instead of days.
    var testFlagSeconds: Bool { get set }
    //Logs
    var verbose: Bool { get set }

    //Flag to define if we want the notifications to be schedule at the same time, or one by one.
    var oneByOne: Bool { get set }

}

extension NSDate {
    class func add(type: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: type, value: value, to: Date())!
    }
}
