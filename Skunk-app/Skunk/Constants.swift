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
    
    // UI strings
    static let HUDProgressText = "Working"
    
    // Debug settings
    static let debugUserIdentifier = Uid(12345)
    
    // Server endpoints
    struct Endpoints {
        static let baseURLHost = "68.234.146.84"
        static let baseURLPort = "3800"
        static let baseURL = NSURL(string: "http://\(baseURLHost):\(baseURLPort)")!
        
        static let usersCreateURL = baseURL.URLByAppendingPathComponent("/users/create")
        static let usersLoginURL = baseURL.URLByAppendingPathComponent("/users/login/")
        
        static let sessionsURL = baseURL.URLByAppendingPathComponent("/sessions/")
        
        static let sessionsCreateURL = baseURL.URLByAppendingPathComponent("/sessions/create")
        
    }
    
    // In seconds
    static let serverTimeout = NSTimeInterval(30.0)
    
    // HTTP Response Codes
    static let statusOK = 200
    
    struct Storyboards {
        static let launchScreen = "LaunchScreen"
        static let login = "Login"
        static let main = "Main"
    }
}