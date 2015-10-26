//
//  MainTabBarController.swift
//  Skunk
//
//  Created by Josh on 9/24/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

import OHHTTPStubs

class MainTabBarController: UITabBarController {
    
    var accountManager: UserAccountManager!
    var locationManager: LocationManager!
    var sessionManager: ShareSessionManager!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        locationManager = LocationManager()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // At this controller we are guaranteed to have an initialized and saved RegisteredUserAcccount.
        assert(accountManager.registeredAccount != nil)
        sessionManager = ShareSessionManager(account: accountManager.registeredAccount!)
        
        let shareNavController = viewControllers![0] as! UINavigationController
        let shareController = shareNavController.viewControllers.first! as! ShareMainViewController
        shareController.accountManager = accountManager
        shareController.locationManager = locationManager
        shareController.sessionManager = sessionManager
        
        let receiveNavController = viewControllers![1] as! UINavigationController
        let receiveController = receiveNavController.viewControllers.first! as! ReceiveFriendsListViewController
        receiveController.accountManager = accountManager
        receiveController.sessionManager = sessionManager
        
        let settingsNavController = viewControllers![2] as! UINavigationController
        let settingsController = settingsNavController.viewControllers.first! as! SettingsViewController
        settingsController.accountManager = accountManager
        
        if accountManager.registeredAccount!.userAccount.debug {
            self.mockDebugRequests()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "driverRequested:", name: Constants.Notifications.sessionStart, object: nil)
    }
    
    func driverRequested(notification: NSNotification) {
        switch notification.name {
        case Constants.Notifications.sessionStart:
            let json = notification.userInfo as! [String: AnyObject]
            let sessionJSON = json["session"] as! [String: AnyObject]
            guard let shareSession = ShareSessionManager.parseShareSession(sessionJSON) else {
                return
            }
            
            if shareSession.needsDriver {
                self.presentDecisionAlert("Can you be a driver for this sharer?", OKHandler: { (action) -> Void in
                    self.sessionManager.sessionDriverResponse(shareSession, completion: { (success) -> () in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let sharerAccount = shareSession.sharerAccount.userAccount
                            let sharerName = "\(sharerAccount.firstName) \(sharerAccount.lastName)"
                            let message = success ? "You have been marked as the driver for \(sharerName)." : "Failed to respond as driver"
                            self.presentErrorAlert(message)
                        })
                    })
                })
            }
        case Constants.Notifications.sessionEnd:
            break
        case Constants.Notifications.pickupRequest:
            break
        case Constants.Notifications.pickupResponse:
            break
        default:
            print("Warning: Unrecognized remote notification category: '\(notification.name)'")
        }
    }
    
    private func mockDebugRequests() {
        stub(isPath(Constants.Endpoints.usersFindURL.path!), response: { _ in
            let path = OHPathForFile("find.json", self.dynamicType)
            return fixture(path!, status: 200, headers: ["Content-Type": "application/json"])
        })
        
        stub(isPath(Constants.Endpoints.sessionsCreateURL.path!), response: { _ in
            let path = OHPathForFile("session_create.json", self.dynamicType)
            return fixture(path!, status: 200, headers: ["Content-Type": "application/json"])
        })
        
        // This session ID must match the ID given in session_create.json
        let sessionsURL = Constants.Endpoints.sessionsURL.URLByAppendingPathComponent("555")
        
        stub(isPath(sessionsURL.path!), response: { _ in
            let path = OHPathForFile("session_heartbeat.json", self.dynamicType)
            return fixture(path!, status: 200, headers: ["Content-Type": "application/json"])
        })
        
        stub(isPath(Constants.Endpoints.sessionsURL.path!), response: { _ in
            let path = OHPathForFile("session_return.json", self.dynamicType)
            return fixture(path!, status: 200, headers: ["Content-Type": "application/json"])   
        })

        let pickupRequestURL = sessionsURL.URLByAppendingPathComponent(Constants.Endpoints.sessionsPickupRequestPath)

        stub(isPath(pickupRequestURL.path!), response: { _ in
            return OHHTTPStubsResponse(data: NSData(), statusCode: 204, headers: nil)
        })
        
        let getSessionID = Constants.Endpoints.createSessionURL(1, path: nil);
        
        stub(isPath( getSessionID.path! ), response: { _ in
            let path = OHPathForFile("shareSessionHeartbeat.json", self.dynamicType)
            return fixture(path!, status: 200, headers: ["Content-Type": "application/json"])
        })

    }
}
