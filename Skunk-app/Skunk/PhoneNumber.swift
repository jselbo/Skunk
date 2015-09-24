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
        
        // Extract only number characters
        let nonDigitCharacters = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        let digitsOnly = text.componentsSeparatedByCharactersInSet(nonDigitCharacters).joinWithSeparator("")
        
        // Ensure number of digits is what we expect
        guard digitsOnly.characters.count == expectedDigits else {
            return nil
        }
        
        sanitizedText = digitsOnly
    }
    
}
