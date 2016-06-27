//
//  ACPReminder.swift
//  ACPReminder
//
//  Created by Palmero, Antonio on 27/06/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//

class ACPReminder {
    
    var randomMessage : Boolean = false
    var circularTimePeriod : Boolean = false
    var appDomain : String = ""
    var messages : [String] = []
    var timePeriods : [Int] = []
    var testFlagSeconds : Boolean = false
    
    static let sharedInstance = ACPReminder()
    
    private init() {
        
    }
    
}
