//
//  ACPReminderNotification.swift
//  ACPReminder
//
//  Created by Palmero, Antonio on 27/06/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//


class ACPReminderNotification: NSObject {

    typealias notificationActionType = () -> Void
    let notificationTitle : String
    let notificationAction : notificationActionType
    
    init(message: String, action: notificationActionType) {
        self.notificationTitle = message;
        self.notificationAction = action;
    }
}
