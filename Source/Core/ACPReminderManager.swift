//
//  ACPReminder.swift
//  ACPReminder
//
//  Created by Palmero, Antonio on 27/06/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//
import UserNotifications

public class ACPReminderManager {

    enum ReminderError : Error {
        case noTimePeriodDefined
        case somethingWentWrong
    }

    public let configuration: ACPReminderConfiguration
    fileprivate var lastNotificationIdentifier: String {
        get { return userDefaults.string(forKey: "last")! }
        set { return userDefaults.set(lastNotificationIdentifier, forKey: "last") }
    }

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

    init(configuration: ACPReminderConfiguration) {
        self.configuration = configuration
    }

    public func createNotification() {

        guard !self.configuration.messages.isEmpty else {
            ACPLog("WARNING: You dont have any message defined!");
            return;
        }

        self.cancelCurrentNotification()
        let timePeriod = try! self.timePeriod()
        let dateToFire = Date.add(type: .second, value: Int(timePeriod))
        let messageIndex = self.messageIndex()
        let notification = configuration.messages[messageIndex]
        queue(notification: notification, date: dateToFire)
        lastTimePeriodIndex = timePeriod
        lastMessageIndex = messageIndex
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
            let pendingNotification = $0.flatMap{ $0.identifier }
                                        .filter{ $0.contains("acpreminder_time_interval" )}
            self.notificationCenter.removeDeliveredNotifications(withIdentifiers:pendingNotification)
            pendingNotification.first.then{ self.lastNotificationIdentifier = $0 }
        })
    }

    fileprivate func isTriggered() -> Bool {
        var isTriggered = true
        notificationCenter.getPendingNotificationRequests(completionHandler: {
            let pendingNotification = $0.flatMap{ $0.identifier }
                .filter{ $0.contains("acpreminder_time_interval" )}
                .first
                .then{ (_) in isTriggered = false }
        })
        return isTriggered
    }

    fileprivate func change(oldNotification:String) {
        self.notifications.next(item: oldNotification).then{
            self.lastNotificationIdentifier = $0
        }
        ACPLog("Notification time period has changed from \(oldNotification) to \(lastNotificationIdentifier)");
    }

    fileprivate func messageIndex() -> Int {
        if (configuration.randomMessage){
            return Int(arc4random_uniform(UInt32(Int32(self.configuration.messages.count))))
        } else {
            var newIndex = (isTriggered()) ? lastMessageIndex+1 : lastMessageIndex
            newIndex = (newIndex <= self.configuration.messages.count) ? newIndex : 0
            return newIndex
        }
    }

    fileprivate func timePeriod() throws -> Int {
        guard !configuration.timePeriods.isEmpty else {
            ACPLog("WARNING: You dont have any time period defined!");
            throw ReminderError.noTimePeriodDefined
        }
        var newTimePeriod = self.lastTimePeriodIndex + 1
        newTimePeriod = (newTimePeriod <= self.configuration.timePeriods.count) ? newTimePeriod : 0;
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


public protocol ACPReminderConfiguration {
    var debug: Bool { get }
    //If the flag is YES, the message will be selected from the array randomly, if NO sequentially
    var randomMessage: Bool { get }
    //The array of time periods is sequential, if the falg is set to YES when the last element is taken, the next one will be the first element.
    var circularTimePeriod: Bool { get }
    // This attribute define the domain of your notifications, prevent collisions between notifications with other applications using the same library.
    var appDomain: String { get }
    //Array of strings, contains the messages that you want to present as local notifications.
    var messages: [ACPReminderNotification] { get }
    //Array of time periods between the one local notification presented and the next one.
    var timePeriods: [Int] { get }
    //This flag is available only for test purpose, in case you enable it, the time interval from the array timePeriods will be seconds instead of days.
    var testFlagSeconds: Bool { get }
    //Logs
    var verbose: Bool { get }
    //Flag to define if we want the notifications to be schedule at the same time, or one by one.
    var oneByOne: Bool { get }
}

extension Date {
    enum SpecialDates : Int {
        case monday = 2
        case thuesday = 3
        case wednesday = 4
        case thursday = 5
        case friday = 6
        case saturday = 7
        case sunday = 1
        case firstDayMonth = -1
        case lastDayMonth = -2
    }

    private static func componentFlags() -> Set<Calendar.Component> { return [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day, Calendar.Component.weekOfYear, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second, Calendar.Component.weekday, Calendar.Component.weekdayOrdinal, Calendar.Component.weekOfYear] }


    private static func components(_ fromDate: Date) -> DateComponents! {
        return Calendar.current.dateComponents(Date.componentFlags(), from: fromDate)
    }

    public func components() -> DateComponents  {
        return Date.components(self)!
    }

    static func date(atLast days:Int, on first:SpecialDates) -> Date {
        let date = Date.add(type: .day, value: days)
        return date
    }

    static func add(type: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: type, value: value, to: Date())!
    }

    static func startOfMonth(after: Date) -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: after)))!
    }

    static func endOfMonth(after: Date) -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth(after: after))!
    }

    static func get(myDate: Date, weekday: SpecialDates) -> Date {
        let cal = Calendar.current
        var comps = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: myDate)
        comps.weekday = SpecialDates.RawValue()
        let mondayInWeek = cal.date(from: comps)!
        return mondayInWeek
    }

    func dateAtStartOfWeek() -> Date
    {
        let flags: Set<Calendar.Component> = [Calendar.Component.year, Calendar.Component.month, Calendar.Component.weekOfYear, Calendar.Component.weekday]
        var components = Calendar.current.dateComponents(flags, from: self)
        components.weekday = Calendar.current.firstWeekday
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)!
    }


    func dateAtEndOfWeek() -> Date
    {
        let flags: Set<Calendar.Component> = [Calendar.Component.year, Calendar.Component.month, Calendar.Component.weekOfYear, Calendar.Component.weekday]
        var components = Calendar.current.dateComponents(flags, from: self)
        components.weekday = Calendar.current.firstWeekday + 6
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)!
    }

    func dateAtTheStartOfMonth() -> Date
    {
        //Create the date components
        var components = self.components()
        components.day = 1
        //Builds the first day of the month
        let firstDayOfMonthDate :Date = Calendar.current.date(from: components)!

        return firstDayOfMonthDate

    }

    func dateAtTheEndOfMonth() -> Date {

        //Create the date components
        var components = self.components()
        //Set the last day of this month
        components.month = (components.month ?? 0) + 1
        components.day = 0

        //Builds the first day of the month
        let lastDayOfMonth :Date = Calendar.current.date(from: components)!

        return lastDayOfMonth

    }

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
