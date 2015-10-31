//
//  ShareSessionManager.swift
//  Skunk
//
//  Created by Josh on 9/21/15.
//  Copyright © 2015 CS408. All rights reserved.
//


import Foundation
import CoreLocation

class ShareSessionManager: NSObject, NSURLSessionDelegate {
    let account: RegisteredUserAccount
    var sharerInformation = [Uid : ShareSession]()
    
    init(account: RegisteredUserAccount) {
        self.account = account
    }
    
    // On success, the ShareSession object is assigned a session identifier and success is true.
    func registerSession(session: ShareSession, completion: (success: Bool) -> ()) {
        
        let params = session.serializeForCreate()
        
        let request = ServerRequest(type: .POST, url: Constants.Endpoints.sessionsCreateURL)
        request.expectedContentType = .JSON
        request.expectedBodyType = .JSONObject
        request.additionalHTTPHeaders =
            [Constants.userIDHeader: "\(session.sharerAccount.identifier)"]
        request.execute(params) { (response) -> Void in
            switch (response) {
            case .Success(let response):
                let JSONResponse = response as! [String: AnyObject]
                
                guard let identifier = JSONResponse["id"] as? Int else {
                    print("Error: Failed to parse values from JSON: \(JSONResponse)")
                    completion(success: false)
                    break
                }
                session.identifier = Sid(identifier)
                completion(success: true)
                
            case .Failure(let failure):
                request.logResponseFailure(failure)
                completion(success: false)
            }
        }
    }

    func sendLocationHeartbeat(session: ShareSession, location: CLLocation, completion: (success: Bool) -> ()) {
        let sessionURL = Constants.Endpoints.createSessionURL(session.identifier!, path: nil)
        let request = ServerRequest(type: .POST, url: sessionURL)
        request.expectedContentType = .JSON
        request.expectedBodyType = .JSONObject
        request.additionalHTTPHeaders =
            [Constants.userIDHeader: "\(session.sharerAccount.identifier)"]
        let params = [
            "location": location.serializeISO6709(),
        ]
        request.execute(params) { (response) -> Void in
            switch response {
            case .Success(let response):
                let responseJSON = response as! [String: AnyObject]
                
                guard let
                    terminated = responseJSON["terminated"] as? Bool,
                    receiverInfoJSON = responseJSON["receiver_info"] as? [String: AnyObject]
                else {
                    print("Error: Failed to parse session from JSON: \(responseJSON)")
                    completion(success: false)
                    return
                }
                
                // First, check for termination
                if terminated {
                    session.terminated = true
                    completion(success: true)
                }
                
                // Check for receiver session termination responses
                for receiverInfo in receiverInfoJSON {
                    guard let receiverID = Uid(receiverInfo.0) else {
                        print("Error: Failed to parse receiver ID from JSON: \(responseJSON)")
                        completion(success: false)
                        return
                    }
                    guard let receiverEnded = receiverInfo.1 as? Bool else {
                        print("Error: Failed to parse receiver ended flag from JSON: \(responseJSON)")
                        completion(success: false)
                        return
                    }
                    guard let receiverInfo = session.findReceiver(receiverID) else {
                        print("Error: Invalid receiver ID: \(receiverID)")
                        completion(success: false)
                        return
                    }
                    
                    if receiverEnded {
                        receiverInfo.stopSharingState = .Accepted
                    }
                }
                
                // Check for driver acceptance
                if let driverID = responseJSON["driver_id"] as? Int where session.driverIdentifier == nil {
                    session.driverIdentifier = Uid(driverID)
                }
                
                // Check for pickup response
                if let driverETA = responseJSON["driver_eta"] as? String where session.driverIdentifier != nil {
                    guard let driverETADate = driverETA.parseSQLDate() else {
                        print("Error: Failed to parse Driver ETA date from string: '\(driverETA)'")
                        completion(success: false)
                        return
                    }
                    session.driverEstimatedArrival = driverETADate
                }
                
                completion(success: true)
            
            case .Failure(let failure):
                request.logResponseFailure(failure)
                completion(success: false)
            }
        }
    }
    
    
    func fetchShareSession(
        account: RegisteredUserAccount,
        identifier: Sid,
        completion:(session: ShareSession?) -> ()) {
        let sessionURL = Constants.Endpoints.createSessionURL(identifier, path: nil)
        let request = ServerRequest(type: .GET, url: sessionURL)
        request.expectedContentType = .JSON
        request.expectedBodyType = .JSONObject
        request.additionalHTTPHeaders =
            [Constants.userIDHeader: "\(account.identifier)"]
        request.execute() { (response) -> Void in
            switch (response) {
            case .Success(let response):
                guard let shareSession = ShareSessionManager.parseShareSession(response as! [String: AnyObject]) else {
                    print("Failed to parse session from JSON: \(response)")
                    completion(session: nil)
                    return
                }
                
                completion(session: shareSession)

            case .Failure(let failure):
                request.logResponseFailure(failure)
                completion(session: nil)
            }
        }
    }
    
    func fetchShareSessions(
        account: RegisteredUserAccount,
        completion: (registeredAccounts : [RegisteredUserAccount]?) -> ()) {
        self.sharerInformation.removeAll()
        
        var sharerList = [RegisteredUserAccount]()
        let request = ServerRequest(type: .GET, url: Constants.Endpoints.sessionsBaseURL)
        request.expectedContentType = .JSON
        request.expectedBodyType = .JSONArray
        request.additionalHTTPHeaders =
            [Constants.userIDHeader: "\(account.identifier)"]
        request.execute() { (response) -> Void in
            switch (response) {
            case .Success(let response):
                let JSONResponse = response as! [AnyObject]
                for responseData in JSONResponse {
                    guard let sessionJSON = responseData as? [String: AnyObject] else {
                        print("Failed to parse session object from JSON array: \(responseData)")
                        completion(registeredAccounts: nil)
                        return
                    }
                    guard let shareSession = ShareSessionManager.parseShareSession(sessionJSON) else {
                        print("Failed to parse session from JSON: \(sessionJSON)")
                        completion(registeredAccounts: nil)
                        return
                    }
                    
                    sharerList.append(shareSession.sharerAccount)
                    
                    let sharerID = Uid(shareSession.sharerAccount.identifier)
                    self.sharerInformation[sharerID] = shareSession
                }
                completion(registeredAccounts: sharerList)
            case .Failure(let failure):
                request.logResponseFailure(failure)
                completion(registeredAccounts: nil)
            }
        }
    }
    
    //Session Term Request
    func sessionTermRequest(session: ShareSession, receiver: ReceiverInfo, completion:(success: Bool)->()) {
        receiver.stopSharingState = .Requested
        let params = [
            "receivers": [NSNumber(unsignedLongLong: receiver.account.identifier)],
        ]
        let sessionURL = Constants.Endpoints.createSessionURL(session.identifier!,
            path: Constants.Endpoints.sessionsTerminateRequestPath)
        let request = ServerRequest(type: .POST, url: sessionURL)
        request.expectedStatusCode = Constants.nilContent
        request.additionalHTTPHeaders =
            [Constants.userIDHeader: "\(session.sharerAccount.identifier)"]
        request.execute(params) { (response) -> Void in
            NSThread.sleepForTimeInterval(5)
            switch (response) {
            case .Success(_):
                completion(success: true)
            case .Failure(let failure):
                receiver.stopSharingState = .None
                request.logResponseFailure(failure)
                completion(success: false)
            }
        }
    }
    
    // Session Terminate Response 
    func sessionTermResponse(session: ShareSession, receiver: RegisteredUserAccount, completion:(success: Bool)->()) {
        let params = [
            "response": true
        ]
        let sessionURL = Constants.Endpoints.createSessionURL(session.identifier!,
            path: Constants.Endpoints.sessionsTerminateResponsePath)
        let request = ServerRequest(type: .POST, url: sessionURL)
        request.expectedStatusCode = Constants.nilContent
        request.additionalHTTPHeaders =
            [Constants.userIDHeader: "\(receiver.identifier)"]
        request.execute(params) { (response) -> Void in
            switch (response) {
            case .Success(_):
                completion(success: true)
            case .Failure(let failure):
                request.logResponseFailure(failure)
                completion(success: false)
            }
        }
    }
    
    // Session PickUp Request
    func sessionPickUpRequest(session: ShareSession, completion:(success: Bool)->()) {
        let sessionURL = Constants.Endpoints.createSessionURL(session.identifier!,
            path: Constants.Endpoints.sessionsPickupRequestPath)
        let request = ServerRequest(type: .POST, url: sessionURL)
        request.expectedStatusCode = Constants.nilContent
        request.additionalHTTPHeaders =
            [Constants.userIDHeader: "\(session.sharerAccount.identifier)"]
        request.execute() { (response) -> Void in
            switch (response) {
            case .Success(_):
                completion(success: true)
            case .Failure(let failure):
                request.logResponseFailure(failure)
                completion(success: false)
            }
        }
    }
    
    // Session PickUp Response
    func sessionPickUpResponse(session: ShareSession, completion:(success: Bool)->()) {
        let params = [
            "response": true,
            "eta": session.driverEstimatedArrival!.serializeISO8601()
        ]
        let sessionURL = Constants.Endpoints.createSessionURL(session.identifier!,
            path: Constants.Endpoints.sessionsPickupResponsePath)
        let request = ServerRequest(type: .POST, url: sessionURL)
        request.expectedStatusCode = Constants.nilContent
        request.additionalHTTPHeaders =
            [Constants.userIDHeader: "\(session.sharerAccount.identifier)"]
        request.execute(params) { (response) -> Void in
            switch (response) {
            case .Success(_):
                completion(success: true)
            case .Failure(let failure):
                request.logResponseFailure(failure)
                completion(success: false)
            }
        }
    }
    
    // Session Driver Response
    func sessionDriverResponse(session: ShareSession, receiver: RegisteredUserAccount, completion:(success: Bool)->()) {
        let params = [
            "response": true,
        ]
        let sessionURL = Constants.Endpoints.createSessionURL(session.identifier!,
            path: Constants.Endpoints.sessionsDriverResponsePath)
        let request = ServerRequest(type: .POST, url: sessionURL)
        request.expectedStatusCode = Constants.nilContent
        request.additionalHTTPHeaders =
            [Constants.userIDHeader: "\(receiver.identifier)"]
        request.execute(params) { (response) -> Void in
            switch (response) {
            case .Success(_):
                completion(success: true)
            case .Failure(let failure):
                request.logResponseFailure(failure)
                completion(success: false)
            }
        }
    }
    
    static func parseShareSession(jsonData: [String: AnyObject]) -> ShareSession? {
        guard let
            needsDriver = jsonData["needs_driver"] as? Bool,
            isTimeBased = jsonData["is_time_based"] as? Bool,
            sessionIdentifier = jsonData["id"] as? Int,
            sharer = jsonData["sharer"] as? [String: AnyObject],
            firstName = sharer["first_name"] as? String,
            lastName = sharer["last_name"] as? String,
            phoneNumberString = sharer["phone_number"] as? String,
            phoneNumber = PhoneNumber(text: phoneNumberString),
            userID = sharer["id"] as? Int
        else {
            print("Error: Failed to parse values from JSON: \(jsonData)")
            return nil
        }
        let userAccount = UserAccount(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber)
        let account = RegisteredUserAccount(userAccount: userAccount, identifier: Uid(userID))
        let shareSession: ShareSession
        if isTimeBased {
            let endTime = jsonData["end_time"] as? String
            guard let endTimeDate = endTime?.parseSQLDate() else {
                print("Error: Failed to parse end date from string: \(endTime)")
                return nil
            }
            shareSession = ShareSession(sharerAccount: account, endCondition: .Time(endTimeDate), needsDriver: needsDriver, receivers: [])
            shareSession.identifier = Sid(sessionIdentifier)
        } else {
            let destination = jsonData["destination"] as! String
            let components = destination.componentsSeparatedByString(",")
            shareSession = ShareSession(sharerAccount: account, endCondition: .Location(CLLocation(latitude: Double(components[0])!, longitude: Double(components[1])!)) , needsDriver: needsDriver, receivers: [])
            shareSession.identifier = Sid(sessionIdentifier)
        }
        if let driverAccount = jsonData["driver"] as? [String: AnyObject],
            driverIdentifier = driverAccount["id"] as? Int {
                shareSession.driverIdentifier = Sid(driverIdentifier)
        }
        
        let driverETA = jsonData["driver_eta"] as? String
        shareSession.driverEstimatedArrival = driverETA?.parseSQLDate()
        
        if let currentLocation = jsonData["current_location"] as? String {
            let components = currentLocation.componentsSeparatedByString(",")
            shareSession.currentLocation = CLLocation(latitude: Double(components[0])!, longitude: Double(components[1])!)
        }
        
        let lastUpdated = jsonData["last_updated"] as? String
        shareSession.lastLocationUpdate = lastUpdated?.parseSQLDate()
        return shareSession
    }
    
    static func parseSessionFromNotification(notification: NSNotification) -> ShareSession? {
        let json = notification.userInfo as! [String: AnyObject]
        let sessionJSON = json["session"] as! [String: AnyObject]
        return ShareSessionManager.parseShareSession(sessionJSON)
    }
}
