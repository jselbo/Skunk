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
    let phoneNumber: PhoneNumber
    /// Used to authenticate user. Only non-nil for the operating user's account.
    let password: String?
    
    override var debugDescription: String {
        get {
            return "UserAccount {name: '\(firstName) \(lastName)', phone: '\(phoneNumber.debugDescription)', pass: \(password)}"
        }
    }
    
    convenience init(firstName: String, lastName: String, phoneNumber: PhoneNumber) {
        self.init(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, password: nil)
    }
    
    init(firstName: String, lastName: String, phoneNumber: PhoneNumber, password: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.password = password
    }

}
