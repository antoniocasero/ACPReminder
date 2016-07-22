//
//  ACPReminder.swift
//  ACPReminder
//
//  Created by Palmero, Antonio on 27/06/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//
import UserNotifications

public class ACPReminderManager {
    //If the flag is YES, the message will be selected from the array randomly, if NO sequentially
    public var randomMessage : Boolean = false
    //The array of time periods is sequential, if the falg is set to YES when the last element is taken, the next one will be the first element.
    public var circularTimePeriod : Boolean = false
    // This attribute define the domain of your notifications, prevent collisions between notifications with other applications using the same library.
    public var appDomain : String = ""
    //Array of strings, contains the messages that you want to present as local notifications.
    public var messages : [String] = []
    //Array of time periods between the one local notification presented and the next one.
    public var timePeriods : [Int] = []
    //This flag is available only for test purpose, in case you enable it, the time interval from the array timePeriods will be seconds instead of days.
    public var testFlagSeconds : Boolean = false
    //Logs
    public var verbose : Boolean = true
    
    public static let sharedInstance = ACPReminderManager()

    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let center = UNUserNotificationCenter.current()
    private var notifications: [String] = []
    
    init() {

    }
    
    public func createLocalNotification() {
        guard messages.count>0 else {
            ACPLog("WARNING: You dont have any message defined!");
            return
        }
        self.center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "title"
        content.body = "body"
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = "time_interval_\(NSDate())"
        notifications.append(identifier)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            ACPLog("error: \(error)")
        }
    }
}


func ACPLog<T>( _ object: @autoclosure() -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    #if DEBUG
        let fileURL = NSURL(string: file)?.lastPathComponent ?? "Unknown file"
        let queue = Thread.isMainThread() ? "UI" : "BG"
        print("<\(queue)> \(fileURL) \(function)[\(line)]: \(object())")
    #endif
}
