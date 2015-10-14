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
    
    
    func createSession(session: ShareSession) {
        /*
        let params = [
           "receivers": 
           "condition": {
             "type": "time" | "location",
             "data": <timestamp> | <location_json>
           },
           "needs_driver": true | false
        ]*/
        
        let request = ServerRequest(type: .POST, url: Constants.Endpoints.sessionsCreateURL)
        request.expectedContentType = .JSON
        request.expectedBodyType = .JSONObject
        /*
        request.execute(params) { (response) -> Void in
            switch (response) {
            case .Success(let response):
                
                //Change logic here to fit create Session Needs
                let JSONResponse = response as! [String: AnyObject]
                
                guard let identifierString = JSONResponse["userID"] as? String, identifier = Uid(identifierString) else {
                    print("Error: Failed to parse values from JSON: \(JSONResponse)")
                    completion(registeredAccount: nil)
                    break
                }
                
                let registered = RegisteredUserAccount(userAccount: account, identifier: identifier)
                completion(registeredAccount: registered)
                
                break
            case .Failure(let failure):
                request.logResponseFailure(failure)
                completion(registeredAccount: nil)
                break
            }
        }
*/

    }
}
