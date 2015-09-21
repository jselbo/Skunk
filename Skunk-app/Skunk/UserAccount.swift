//
//  UserAccount.swift
//  Skunk
//
//  Created by Josh on 9/20/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

/// Account information for a single user.
class UserAccount: NSObject {
    let firstName: String
    let lastName: String
    
    /// The unique identifier for a user.
    let phoneNumber: String
    
    init(firstName: String, lastName: String, phoneNumber: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
    }
}
