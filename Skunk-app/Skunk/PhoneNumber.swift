//
//  PhoneNumber.swift
//  Skunk
//
//  Created by Josh on 9/24/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import Foundation

/// Represents a US (+1) area code, parsed and sanitized.
class PhoneNumber: NSObject, CustomDebugStringConvertible {
    private let expectedDigits = 10
    
    private(set) var sanitizedText = ""
    
    override var debugDescription: String { get { return sanitizedText } }
    
    init?(text: String?) {
        super.init()
        
        // Can't parse nil strings
        guard let text = text else {
            return nil
        }
        
        var parseableText = text
        if text.hasPrefix("+1") {
            parseableText = text.substringFromIndex(text.startIndex.advancedBy(2))
        }
        
        // Extract only number characters
        let nonDigitCharacters = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        let digitsOnly = parseableText.componentsSeparatedByCharactersInSet(nonDigitCharacters).joinWithSeparator("")
        
        // Ensure number of digits is what we expect
        guard digitsOnly.characters.count == expectedDigits else {
            return nil
        }
        
        sanitizedText = digitsOnly
    }
    
    func serialize() -> AnyObject {
        return sanitizedText
    }
    
    func formatForUser() -> String {
        let areaCode = sanitizedText.substringToIndex(sanitizedText.startIndex.advancedBy(3))
        let group1 = sanitizedText.substringWithRange(
            Range<String.Index>(
                start: sanitizedText.startIndex.advancedBy(3),
                end: sanitizedText.startIndex.advancedBy(6)))
        let group2 = sanitizedText.substringWithRange(
            Range<String.Index>(
                start: sanitizedText.startIndex.advancedBy(6),
                end: sanitizedText.startIndex.advancedBy(10)))
        return String(format: "(%@) %@-%@", areaCode, group1, group2)
    }
    
}
