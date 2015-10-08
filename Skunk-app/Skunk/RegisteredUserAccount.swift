//
//  RegisteredUserAccount.swift
//  Skunk
//
//  Created by Josh on 9/21/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

/// A UserAccount which has been verified and registered by the server.
/// When registered, it is assigned
class RegisteredUserAccount: NSObject, CustomDebugStringConvertible {
    let userAccount: UserAccount
    let identifier: Uid
    
    override var debugDescription: String {
        get {
            return "RegisteredUserAccount {id: \(identifier), account: \(userAccount.debugDescription)}"
        }
    }
    
    init(userAccount: UserAccount, identifier: Uid) {
        self.userAccount = userAccount
        self.identifier = identifier
    }
}
