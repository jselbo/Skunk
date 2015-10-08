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
    
    func serializeISO8601() -> String {
        // See https://developer.apple.com/library/mac/qa/qa1480/_index.html for the reason to use en_US_POSIX.
        let dateLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = dateLocale
        dateFormatter.dateFormat = ISO8601DateFormat
        
        return dateFormatter.stringFromDate(self)
    }
    
}
