//
//  UserAccount.swift
//  Skunk
//
//  Created by Josh on 9/20/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

/// Account information for a single user.
class UserAccount: NSObject, CustomDebugStringConvertible {
    let firstName: String
    let lastName: String
    
    /// The unique identifier for a user.
    let phoneNumber: String
    /// Used to authenticate user.
    let password: String
    
    override var debugDescription: String {
        get {
            return "UserAccount {name: '\(firstName) \(lastName)', phone: '\(phoneNumber)', pass: \(password)}"
        }
    }
    
    init(firstName: String, lastName: String, phoneNumber: String, password: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.password = password
    }
}