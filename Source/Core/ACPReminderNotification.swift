//
//  ACPReminderNotification.swift
//  ACPReminder
//
//  Created by Palmero, Antonio on 27/06/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//


class ACPReminderNotification: NSObject {

    typealias notificationAction = () -> void
    let notificationTitle : String;
    let notificationAction : notificationAction
    
    init(message: String, action: notificationAction) {
        notificationTitle = message;
        notificationAction = action;
    }
}
