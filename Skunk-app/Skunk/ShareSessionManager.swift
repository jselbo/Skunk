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
        let sessionURL = Constants.Endpoints.sessionsURL.URLByAppendingPathComponent("\(session.identifier!)")
        let request = ServerRequest(type: .PUT, url: sessionURL)
        request.expectedContentType = .JSON
        request.expectedBodyType = .JSONObject
        request.additionalHTTPHeaders = ["Skunk-UserID": 234]
        let params = [
            "location": location.serializeISO6709(),
        ]
        request.execute(params) { (response) -> Void in
            switch response {
            case .Success(let response):
                let responseJSON = response as! [String: AnyObject]
                
                // First, check for termination
                if let terminated = responseJSON["terminated"] as? Bool {
                    session.terminated = terminated
                    completion(success: true)
                }
                
                // Check for receiver session termination responses
                if let receiversJSON = responseJSON["receivers"] as? [AnyObject] {
                    // Check for all receivers terminated session
                    for receiverJSON in receiversJSON {
                        guard let receiverID = receiverJSON["user_id"] as? Int else {
                            print("Error: Failed to parse receiver ID from JSON: \(responseJSON)")
                            completion(success: false)
                            return
                        }
                        
                        guard let receiverInfo = session.findReceiver(Uid(receiverID)) else {
                            print("Error: Invalid receiver ID: \(receiverID)")
                            completion(success: false)
                            return
                        }
                        
                        // Check for a driver's response
                        if let sharerEnded = receiverJSON["receiver_ended"] as? Bool {
                            if sharerEnded {
                                receiverInfo.stopSharingState = .Accepted
                            }
                        }
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
    
    func sendServerRequestforReceiver(completion: (registeredAccounts : [RegisteredUserAccount]?) -> ()) {
        var sharerList = [RegisteredUserAccount]()
        let request = ServerRequest(type: .GET, url: Constants.Endpoints.sessionsURL)
        request.expectedContentType = .JSON
        request.expectedBodyType = .JSONArray
        request.execute() { (response) -> Void in
            switch (response) {
            case .Success(let response):
                let JSONResponse = response as! [AnyObject]
                for responseData in JSONResponse {
                    guard let sharerSession = responseData["sharer_id"] as? [String:AnyObject],
                        firstName = sharerSession["first_name"] as? String,
                        lastName = sharerSession["last_name"] as? String,
                        phoneNum = sharerSession["phone_number"] as? PhoneNumber,
                        userID = sharerSession["UID"] as? UInt64 ,
                        needsDriver = responseData["needs_driver"] as? Bool,
                        isTimeBased = responseData["is_time_based"] as? Bool,
                        endTime = responseData["end_time"] as? String,
                        destination = responseData["destination"] as? String,
                        lastUpdated = responseData["last_updated"] as? String,
                        driverETA = responseData["driver_eta"] as? String,
                        currentLocation = responseData["current_location"] as? String else {
                            print("Error: Failed to parse values from JSON: \(JSONResponse)")
                            completion(registeredAccounts : nil)
                            return
                    }
                    let userAccount = UserAccount.init(firstName: firstName, lastName: lastName, phoneNumber: phoneNum)
                    let account = RegisteredUserAccount.init(userAccount: userAccount, identifier: Uid(userID))
                    let shareSession: ShareSession
                    if(isTimeBased) {
                        guard let endTimeDate = endTime.parseSQLDate() else {
                            print("Error: Failed to parse end date from string: \(endTime)")
                            completion(registeredAccounts: nil)
                            return
                        }
                        shareSession = ShareSession.init(sharerAccount: account, endCondition: ShareEndCondition.Time(endTimeDate), needsDriver: needsDriver, receivers: [])
                    } else {
                        let components = destination.componentsSeparatedByString(",")
                        shareSession = ShareSession.init(sharerAccount: account, endCondition: ShareEndCondition.Location(CLLocation(latitude: Double(components[0])!, longitude: Double(components[1])!)) , needsDriver: needsDriver, receivers: [])
                    }
                    sharerList.append(account)
                    shareSession.driverEstimatedArrival = driverETA.parseSQLDate()
                    let components = currentLocation.componentsSeparatedByString(",")
                    shareSession.currentLocation = CLLocation(latitude: Double(components[0])!, longitude: Double(components[1])!)
                    shareSession.lastLocationUpdate = lastUpdated.parseSQLDate()
                    self.sharerInformation[Uid(userID)] = shareSession
                }
            case .Failure(let failure):
                request.logResponseFailure(failure)
                break
            }
        }
    }
    
    //Session Term Request
    func sessionTermRequest(session: ShareSession, receiver: ReceiverInfo, completion:(success: Bool)->()) {
        receiver.stopSharingState = .Requested
        let params = [
            "receivers": [NSNumber(unsignedLongLong: receiver.account.identifier)],
        ]
        let url = replaceIdURL(Constants.Endpoints.sessionTermRequest, id: session.identifier! )
        let request = ServerRequest(type: .POST, url: NSURL(fileURLWithPath: url))
        request.expectedStatusCode = Constants.nilContent
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
    func sessionTermResponse(session: ShareSession, completion:(success: Bool)->()){
        let params = [
            "response": true
        ]
        let url = replaceIdURL(Constants.Endpoints.sessionTermResponse, id: session.identifier! )
        let request = ServerRequest(type: .POST, url: NSURL(fileURLWithPath: url))
        request.expectedContentType = .JSON
        request.expectedBodyType = .JSONObject
        request.expectedStatusCode = Constants.nilContent
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
        let url = replaceIdURL(Constants.Endpoints.sessionsPickupRequestPath, id: session.identifier! )
        let pickupURL = Constants.Endpoints.baseURL.URLByAppendingPathComponent(url)
        let request = ServerRequest(type: .PUT, url: pickupURL)
        request.expectedStatusCode = Constants.nilContent
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
        let url = replaceIdURL(Constants.Endpoints.sessionsPickupResponse, id: session.identifier! )
        let request = ServerRequest(type: .POST, url: NSURL(fileURLWithPath: url))
        request.expectedStatusCode = Constants.nilContent
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
    func sessionDriverResponse(session: ShareSession, completion:(success: Bool)->()) {
        let params = [
            "response": true,
        ]
        let url = replaceIdURL(Constants.Endpoints.sessionsDriverResponse, id: session.identifier! )
        let responseURL = Constants.Endpoints.baseURL.URLByAppendingPathComponent(url)
        let request = ServerRequest(type: .POST, url: responseURL)
        request.expectedStatusCode = Constants.nilContent
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
    
    private func replaceIdURL(endPoint: String, id: Uid) -> String {
        // TODO (defect) extra slash in URL DOOOOOOOOOOOON
        let sessions = "/sessions/"
        return sessions + id.description + endPoint
    }
}
