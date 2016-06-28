//
//  ACPReminder.swift
//  ACPReminder
//
//  Created by Palmero, Antonio on 27/06/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//
import UserNotifications

class ACPReminder {
    //If the flag is YES, the message will be selected from the array randomly, if NO sequentially
    var randomMessage : Boolean = false
    //The array of time periods is sequential, if the falg is set to YES when the last element is taken, the next one will be the first element.
    var circularTimePeriod : Boolean = false
    // This attribute define the domain of your notifications, prevent collisions between notifications with other applications using the same library.
    var appDomain : String = ""
    //Array of strings, contains the messages that you want to present as local notifications.
    var messages : [String] = []
    //Array of time periods between the one local notification presented and the next one.
    var timePeriods : [Int] = []
    //This flag is available only for test purpose, in case you enable it, the time interval from the array timePeriods will be seconds instead of days.
    var testFlagSeconds : Boolean = false
    
    static let sharedInstance = ACPReminder()
    
    private let center = UNUserNotificationCenter.current()
    private var notifications: [String] = []
    
    private init() {

    }
    
    internal func createLocalNotification() {
        guard messages.count>0 else {
            ACPLog("WARNING: You dont have any message defined!");
            return
        }
        self.center.removePendingNotificationRequests(withIdentifiers: []);
        
        let content = UNMutableNotificationContent()
        content.title = "title"
        content.body = "body"
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = "time_interval_\(NSDate())"
        notifications.append(identifier)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            print("error: \(error)")
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
