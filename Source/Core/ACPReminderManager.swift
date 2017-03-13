//
//  ACPReminder.swift
//  ACPReminder
//
//  Created by Palmero, Antonio on 27/06/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//
import UserNotifications

public class ACPReminderManager {

    enum ReminderError: Error {
        case noTimePeriodDefined
        case somethingWentWrong
    }

    public let configuration: ACPReminderConfiguration

    fileprivate var lastMessageIndex: Int {
        get { return userDefaults.integer(forKey: "lastMessageIndex") }
        set { return userDefaults.set(lastMessageIndex, forKey: "lastMessageIndex") }
    }

    fileprivate var lastTimePeriodIndex: Int {
        get { return userDefaults.integer(forKey: "lastTimeIndex") }
        set { return userDefaults.set(lastMessageIndex, forKey: "lastTimeIndex") }
    }

    fileprivate let userDefaults = UserDefaults.standard
    fileprivate let notificationCenter = UNUserNotificationCenter.current()
    fileprivate var notifications: [String] = []

    public init(configuration: ACPReminderConfiguration) {
        self.configuration = configuration
    }

    public func createNotification() {

        guard !self.configuration.messages.isEmpty else {
            ACPLog("WARNING: You dont have any message defined!")
            return
        }
        self.cancelCurrentNotification()
        let timePeriod = self.timePeriod()
        let dateToFire = Date.add(type: .second, value: Int(timePeriod))
        let messageIndex = self.messageIndex()
        let notification = configuration.messages[messageIndex]
        queue(notification: notification, date: dateToFire)
        lastTimePeriodIndex = timePeriod
        lastMessageIndex = messageIndex

        ACPLog("This notification has been fired: \(notification.description) with this period: \(lastTimePeriodIndex)")

    }

    public func notifcationHasBeenTriggered() {
        if !self.isTriggered() {
            self.next(messageIndex: self.lastMessageIndex)
        }
    }

    fileprivate func queue(notification: ACPReminderNotification, date: Date) {

        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.message
        content.sound = notification.sound
        content.attachments = []
        let trigger = UNCalendarNotificationTrigger(dateMatching: date.components(), repeats: false)
        let identifier = "\(configuration.appDomain)_time_interval_\(Date())"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            ACPLog("error: \(error)")
        }

    }

    fileprivate func cancelCurrentNotification() {
        notificationCenter.getPendingNotificationRequests(completionHandler: {
            let pendingNotification = $0.flatMap { $0.identifier }
                                        .filter { $0.contains("acpreminder_time_interval" )}
            self.notificationCenter.removeDeliveredNotifications(withIdentifiers:pendingNotification)
            pendingNotification.first.then { self.lastNotificationIdentifier = $0 }
        })
    }

    fileprivate func isTriggered() -> Bool {
        var isTriggered = true
        notificationCenter.getPendingNotificationRequests(completionHandler: {
            let _ = $0.flatMap { $0.identifier }
                .filter { $0.contains("acpreminder_time_interval" )}
                .first
                .then { (_) in isTriggered = false }
        })
        return isTriggered
    }

    fileprivate func next(messageIndex: Int) {
        self.configuration.timePeriods.next(item: messageIndex).then {
            self.lastMessageIndex = $0
        }
        ACPLog("Notification time period has changed from \(messageIndex) to \(lastMessageIndex)")
    }

    fileprivate func messageIndex() -> Int {
        if configuration.randomMessage {
            return Int(arc4random_uniform(UInt32(Int32(self.configuration.messages.count))))
        } else {
            var newIndex = (isTriggered()) ? lastMessageIndex+1 : lastMessageIndex
            newIndex = (newIndex <= self.configuration.messages.count) ? newIndex : 0
            return newIndex
        }
    }

    fileprivate func timePeriod() -> Int {
        guard !configuration.timePeriods.isEmpty else {
            ACPLog("WARNING: You dont have any time period defined!")
            return 0
        }
        var newTimePeriod = self.lastTimePeriodIndex + 1
        newTimePeriod = (newTimePeriod <= self.configuration.timePeriods.count) ? newTimePeriod : 0
        return newTimePeriod
    }
}

func ACPLog<T>( _ object: @autoclosure() -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    #if DEBUG
        let fileURL = NSURL(string: file)?.lastPathComponent ?? "Unknown file"
        let queue = Thread.isMainThread ? "UI" : "BG"
        print("<\(queue)> \(fileURL) \(function)[\(line)]: \(object())")
    #endif
}

extension Optional {
    // `then` function executes the closure if there is some value
    func then(_ handler: (Wrapped) -> Void) {
        switch self {
        case .some(let wrapped): return handler(wrapped)
        case .none: break
        }
    }
}

extension Array where Element: Hashable {
    func next(item: Element) -> Element? {
        if let index = self.index(of:item), index + 1 < self.count {
            return self[index + 1]
        }
        return nil
    }
}
