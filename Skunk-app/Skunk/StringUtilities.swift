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
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "EST")!
        dateFormatter.dateFormat = ISO8601DateFormat
        return dateFormatter.dateFromString(self)
    }
}
