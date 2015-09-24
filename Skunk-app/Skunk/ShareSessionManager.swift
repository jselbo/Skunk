//
//  ShareSessionManager.swift
//  Skunk
//
//  Created by Josh on 9/21/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import Foundation

class ShareSessionManager: NSObject, NSURLSessionDelegate {
    let account: RegisteredUserAccount
    
    init(account: RegisteredUserAccount) {
        self.account = account
    }
    
    func doPostSessionCreate(session: ShareSession) {
        // var json = session.serializeForCreate()
    }
}
