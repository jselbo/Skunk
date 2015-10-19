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
    
    func replaceIdURL(endPoint: String, id: Uid?) ->String {
        let sessions = "/sessions/"
        return sessions + id!.description + "/" + endPoint
    }
    
    //Session Term Request
    func sessionTermRequest(session: ShareSession, receiver: RegisteredUserAccount, completion:(sucess: Bool)->()) {
        let params = [
            "receivers": [NSNumber(unsignedLongLong: receiver.identifier)],
        ]
        let url = replaceIdURL(Constants.Endpoints.sessionTermRequest, id: session.identifier )
        let request = ServerRequest(type: .POST, url: NSURL(fileURLWithPath: url))
        request.expectedStatusCode = Constants.nilContent
        request.execute(params) { (response) -> Void in
            switch (response) {
            case .Success(_):
                completion(sucess: true)
            case .Failure(let failure):
                request.logResponseFailure(failure)
                completion(sucess: false)
            }
        }
    }
    
    //Session Term Response 
    func sessionTermResponse(session: ShareSession, completion:(sucess: Bool)->()){
        let params = [
            "response": true
        ]
        let url = replaceIdURL(Constants.Endpoints.sessionTermResponse, id: session.identifier )
        let request = ServerRequest(type: .POST, url: NSURL(fileURLWithPath: url))
        request.expectedContentType = .JSON
        request.expectedBodyType = .JSONObject
        request.expectedStatusCode = Constants.nilContent
        request.execute(params) { (response) -> Void in
            switch (response) {
            case .Success(_):
                completion(sucess: true)
            case .Failure(let failure):
                request.logResponseFailure(failure)
                completion(sucess: false)
            }
        }
    }
    
    //Session PickUp Request
    func sessionPickUpRequest(session: ShareSession, completion:(sucess: Bool)->()) {
        let url = replaceIdURL(Constants.Endpoints.sessionsPickupRequest, id: session.identifier )
        let request = ServerRequest(type: .PUT, url: NSURL(fileURLWithPath: url))
        request.expectedStatusCode = Constants.nilContent
        request.execute() { (response) -> Void in
            switch (response) {
            case .Success(_):
                completion(sucess: true)
            case .Failure(let failure):
                request.logResponseFailure(failure)
                completion(sucess: false)
            }
        }
    }
    
    //Session PickUp Response
    func sessionPickUpResponse(session: ShareSession, completion:(sucess: Bool)->()) {
        let params = [
            "response": true,
            "eta": session.driverEstimatedArrival!.serializeISO8601()
        ]
        let url = replaceIdURL(Constants.Endpoints.sessionsPickupResponse, id: session.identifier )
        let request = ServerRequest(type: .POST, url: NSURL(fileURLWithPath: url))
        request.expectedStatusCode = Constants.nilContent
        request.execute(params) { (response) -> Void in
            switch (response) {
            case .Success(_):
                completion(sucess: true)
            case .Failure(let failure):
                request.logResponseFailure(failure)
                completion(sucess: false)
            }
        }
    }
    
    //Session Driver Response
    func sessionDriverResponse(session: ShareSession, completion:(sucess: Bool)->()) {
        let params = [
            "response": true,
        ]
        let url = replaceIdURL(Constants.Endpoints.sessionsDriverResponse, id: session.identifier )
        let request = ServerRequest(type: .POST, url: NSURL(fileURLWithPath: url))
        request.expectedStatusCode = Constants.nilContent
        request.execute(params) { (response) -> Void in
            switch (response) {
            case .Success(_):
                completion(sucess: true)
            case .Failure(let failure):
                request.logResponseFailure(failure)
                completion(sucess: false)
            }
        }
    }
}
