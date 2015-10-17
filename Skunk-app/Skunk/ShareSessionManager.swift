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
                // TODO do something with the returned session object?
                // Will it include any new information?
                let _ = response as! [String: AnyObject]
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
                        //driverID = responseData["driver_id"] as? Int,
                        //startTime = responseData["start_time"] as? String,
                        isTimeBased = responseData["is_time_based"] as? Bool,
                        endTime = responseData["end_time"] as? String,
                        destination = responseData["destination"] as? String,
                        //terminated = responseData["terminated"] as? Bool,
                        lastUpdated = responseData["last_updated"] as? String,
                        //requestedPickup = responseData["requested_pickup"] as? Bool,
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
                        shareSession = ShareSession.init(sharerAccount: account, endCondition: ShareEndCondition.Time(endTime.parseSQLDate()), needsDriver: needsDriver, receivers: [])
                    } else {
                        let components = destination.componentsSeparatedByString(",")
                        shareSession = ShareSession.init(sharerAccount: account, endCondition: ShareEndCondition.Location(CLLocation.init(latitude: Double(components[0])!, longitude: Double(components[1])!)) , needsDriver: needsDriver, receivers: [])
                    }
                    sharerList.append(account)
                    shareSession.driverEstimatedArrival = driverETA.parseSQLDate()
                    let components = currentLocation.componentsSeparatedByString(",")
                    shareSession.currentLocation = CLLocation.init(latitude: Double(components[0])!, longitude: Double(components[1])!)
                    shareSession.lastLocationUpdate = lastUpdated.parseSQLDate()
                    self.sharerInformation[Uid(userID)] = shareSession
                }
            case .Failure(let failure):
                request.logResponseFailure(failure)
                break
            }
        }
    }
}
