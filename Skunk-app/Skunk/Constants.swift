//
//  Constants.swift
//  Skunk
//
//  Created by Josh on 9/21/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import Foundation

// Use a typealias for identifiers so we can easily change the type later if needed
typealias Sid = UInt64
typealias Uid = UInt64

struct Constants {
    static let alertTitle = "Skunk"
    
    // Keys for NSUserDefaults
    static let keyFirstName = "first_name"
    static let keyLastName = "last_name"
    static let keyPhoneNumber = "phone_number"
    
    // For Keychain access
    static let userIdentifierService = "SkunkUserIdentifier"
    static let userPasswordService = "SkunkUserPassword"
    
    static let HUDProgressText = "Working"
    
    struct Storyboards {
        static let launchScreen = "LaunchScreen"
        static let login = "Login"
        static let main = "Main"
    }
}