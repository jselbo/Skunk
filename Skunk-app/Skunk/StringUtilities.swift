//
//  StringUtilities.swift
//  Skunk
//
//  Created by Anant Goel on 10/16/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import Foundation

extension String {
    func parseSQLDate() -> NSDate? {
        let dateLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = dateLocale
        dateFormatter.dateFormat = ISO8601DateFormat
        return dateFormatter.dateFromString(self)
    }
}
