//
//  NSDateUtilities.swift
//  Skunk
//
//  Created by Josh on 9/22/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import Foundation

// See http://stackoverflow.com/a/16254918
let ISO8601DateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

extension NSDate {
    
    func humanizedString() -> String {
        let currentDate = NSDate()
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let currentComponents = calendar.components([.Day], fromDate: currentDate)
        let selectedComponents = calendar.components([.Day], fromDate: self)
        let dayText = (selectedComponents.day == currentComponents.day ? "Today" : "Tomorrow")
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeText = formatter.stringFromDate(self)
        
        let differenceComponents = calendar.components([.Day, .Hour, .Minute], fromDate: currentDate, toDate: self, options: [])
        var hourDifference = Double(differenceComponents.hour)
        hourDifference += Double(differenceComponents.minute) / 60.0
        
        // Round to nearest 0.5
        hourDifference = round(2.0 * hourDifference) / 2.0
        
        let hourText = String(format: "%.1f %@ from now",
            hourDifference, (hourDifference > 1.0 ? "hours" : "hour"))
        return "\(dayText) at \(timeText) (\(hourText))"
    }
    
    func serializeISO8601() -> String {
        // See https://developer.apple.com/library/mac/qa/qa1480/_index.html for the reason to use en_US_POSIX.
        let dateLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = dateLocale
        dateFormatter.dateFormat = ISO8601DateFormat
        
        return dateFormatter.stringFromDate(self)
    }
    
}
