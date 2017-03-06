//
//  Date+Utils.swift
//  ACPReminder
//
//  Created by Palmero, Antonio on 06/03/2017.
//  Copyright © 2017 Uttopia. All rights reserved.
//

import Foundation

extension Date {
    enum SpecialDates: Int {
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

    private static func componentFlags() -> Set<Calendar.Component> { return [Calendar.Component.year,
                                                                              Calendar.Component.month,
                                                                              Calendar.Component.day,
                                                                              Calendar.Component.weekOfYear,
                                                                              Calendar.Component.hour,
                                                                              Calendar.Component.minute,
                                                                              Calendar.Component.second,
                                                                              Calendar.Component.weekday,
                                                                              Calendar.Component.weekdayOrdinal,
                                                                              Calendar.Component.weekOfYear] }

    private static func components(_ fromDate: Date) -> DateComponents! {
        return Calendar.current.dateComponents(Date.componentFlags(), from: fromDate)
    }

    public func components() -> DateComponents {
        return Date.components(self)!
    }

    static func date(atLast days: Int, on first: SpecialDates) -> Date {
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

    func dateAtStartOfWeek() -> Date {
        let flags: Set<Calendar.Component> = [Calendar.Component.year, Calendar.Component.month, Calendar.Component.weekOfYear, Calendar.Component.weekday]
        var components = Calendar.current.dateComponents(flags, from: self)
        components.weekday = Calendar.current.firstWeekday
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)!
    }

    func dateAtEndOfWeek() -> Date {
        let flags: Set<Calendar.Component> = [Calendar.Component.year, Calendar.Component.month, Calendar.Component.weekOfYear, Calendar.Component.weekday]
        var components = Calendar.current.dateComponents(flags, from: self)
        components.weekday = Calendar.current.firstWeekday + 6
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)!
    }

    func dateAtTheStartOfMonth() -> Date {
        //Create the date components
        var components = self.components()
        components.day = 1
        //Builds the first day of the month
        let firstDayOfMonthDate: Date = Calendar.current.date(from: components)!

        return firstDayOfMonthDate

    }

    func dateAtTheEndOfMonth() -> Date {

        //Create the date components
        var components = self.components()
        //Set the last day of this month
        components.month = (components.month ?? 0) + 1
        components.day = 0

        //Builds the first day of the month
        let lastDayOfMonth: Date = Calendar.current.date(from: components)!
        
        return lastDayOfMonth
        
    }
    
}
