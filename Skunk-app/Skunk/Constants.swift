//
//  Constants.swift
//  Skunk
//
//  Created by Josh on 9/21/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

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
    static let needLocationAuthorizationMessage = "Skunk requires location permissions to share your location with family and friends. Please enable location permissions by going to Settings > Skunk > Location and setting access to 'Always'."
    static let needContactsAuthorizationMessage = "Skunk requires contact permissions to match your contacts' phone numbers to other Skunk users. Please enable contact permissions by going to Settings > Skunk and setting Contacts access to on."
    
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
        
        static let usersFind = baseURL.URLByAppendingPathComponent("/users/find")
        
        //handshakes
        static let sessionTermRequest = "/terminate/request"
        static let sessionTermResponse = "/terminate/response"
        static let sessionsPickupRequest = "/pickup/request"
        static let sessionsPickupResponse = "/pickup/response"
        static let sessionsDriverResponse = "/driver/response"

        
    }
    
    // In seconds
    static let serverTimeout = NSTimeInterval(30.0)
    static let heartbeatFrequency = CFTimeInterval(30.0)
    
    // HTTP Response Codes
    static let statusOK = 200
    
    struct Storyboards {
        static let launchScreen = "LaunchScreen"
        static let login = "Login"
        static let main = "Main"
    }
    
    static let systemBlueColor = UIColor(red: 0, green: 0.478431, blue: 1.0, alpha: 1.0)
}