//
//  MyNotifications.swift
//  Example
//
//  Created by Palmero, Antonio on 06/03/2017.
//  Copyright © 2017 Uttopia. All rights reserved.
//

import Foundation
import ACPReminder

struct MyNotifications {

    var messages: [ACPReminderNotification]
    var time: [Int]
    var configuration: ACPReminderConfiguration

    init() {
        messages = [ACPReminderNotification(title:"1", message:"fsdfds"),
                        ACPReminderNotification(title:"2", message:"fsdfds"),
                        ACPReminderNotification(title:"3", message:"fsdfds")]

        time = [5, 6, 10]

        configuration = ACPReminderConfiguration(domain: "my.app.org", messages:messages, timePeriods:time)

    }

}
