//
//  StringUtilities.swift
//  Skunk
//
//  Created by Anant Goel on 10/16/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import Foundation
extension String {
    func parseSQLDate() -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.dateFromString(self)
        return date!
    }
}
