//
//  ACPReminderNotification.swift
//  ACPReminder
//
//  Created by Palmero, Antonio on 27/06/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//
import UserNotifications

public struct ACPReminderNotification {

    typealias Completion = () -> Void
    var title: String
    var message: String
    var attachment: [URL] = []
    var sound = UNNotificationSound.default()
    var action: Completion?

    init(title: String, message: String, attachment: [URL] = [], sound: UNNotificationSound = UNNotificationSound.default(), action: Completion? = nil) {
        self.title = title
        self.message = message
        self.attachment = attachment
        self.sound = sound
        self.action = action
    }
}
