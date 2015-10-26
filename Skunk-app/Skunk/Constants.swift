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
    static let keyDebug = "debug"
    static let keyDeviceToken = "device_token"
    
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
    static let userIDHeader = "Skunk-UserID"
    
    struct Endpoints {
        static let baseURLHost = "68.234.146.84"
        static let baseURLPort = "3001"
        static let baseURL = NSURL(string: "http://\(baseURLHost):\(baseURLPort)")!
        
        static let usersCreateURL = baseURL.URLByAppendingPathComponent("/users/create")
        static let usersLoginURL = baseURL.URLByAppendingPathComponent("/users/login")
        static let usersFindURL = baseURL.URLByAppendingPathComponent("/users/find")
        
        static let sessionsBaseURL = baseURL.URLByAppendingPathComponent("/sessions")
        static let sessionsURL = baseURL.URLByAppendingPathComponent("/sessions/")
        static let sessionsCreateURL = baseURL.URLByAppendingPathComponent("/sessions/create")
        
        // Session handshakes
        static let sessionsTerminateRequestPath = "/terminate/request"
        static let sessionsTerminateResponsePath = "/terminate/response"
        static let sessionsPickupRequestPath = "/pickup/request"
        static let sessionsPickupResponsePath = "/pickup/response"
        static let sessionsDriverResponsePath = "/driver/response"
        
        static func createSessionURL(identifier: Uid, path: String?) -> NSURL {
            let url = sessionsBaseURL.URLByAppendingPathComponent(identifier.description)
            if let path = path {
                return url.URLByAppendingPathComponent(path)
            }
            return url
        }
    }
    
    // Notification categories
    struct Notifications {
        // Sent to receiver when a sharer creates begins sharing
        static let sessionStart = "SESSION_START"
        // Sent to a receiver when a sharer requests to stop sharing
        static let sessionEnd = "SESSION_END"
        // Sent to a receiver when a sharer requests to be picked up
        static let pickupRequest = "PICKUP_REQUEST"
        // Sent to a sharer when a receiver responds to a pickup request
        static let pickupResponse = "PICKUP_RESPONSE"
    }
    
    // In seconds
    static let serverTimeout = NSTimeInterval(30.0)
    static let heartbeatFrequency = CFTimeInterval(5.0)
    static let receiverSessionRefreshInterval = CFTimeInterval(5.0)
    
    // HTTP Response Codes
    static let statusOK = 200
    static let nilContent = 204
    
    struct Storyboards {
        static let launchScreen = "LaunchScreen"
        static let login = "Login"
        static let main = "Main"
    }
    
    static let systemBlueColor = UIColor(red: 0, green: 0.478431, blue: 1.0, alpha: 1.0)
}