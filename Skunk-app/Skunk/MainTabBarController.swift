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
    
    var viewHasAppeared = false
    
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
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "sessionStarted:", name: Constants.Notifications.sessionStart, object: nil)
        notificationCenter.addObserver(self, selector: "sessionEnded:", name: Constants.Notifications.sessionEnd, object: nil)
        notificationCenter.addObserver(self, selector: "pickupRequested:", name: Constants.Notifications.pickupRequest, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !viewHasAppeared {
            viewHasAppeared = true
            
            let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
            appDelegate.fireNotificationFromLaunch()
        }
    }
    
    func sessionStarted(notification: NSNotification) {
        guard let shareSession = ShareSessionManager.parseSessionFromNotification(notification) else {
            return
        }
        
        if shareSession.needsDriver {
            let sharerName = shareSession.sharerAccount.userAccount.fullName
            self.presentDecisionAlert("\(sharerName) has shared their location with you and needs a driver. Would you like to accept the driver request?", OKHandler: { (action) -> Void in
                self.sessionManager.sessionDriverResponse(shareSession, receiver: self.accountManager.registeredAccount!, completion: { (success) -> () in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let message = success ? "You have been marked as the driver for \(sharerName)." : "Failed to respond as driver"
                        self.presentErrorAlert(message)
                    })
                })
            })
        }
    }
    
    func sessionEnded(notification: NSNotification) {
        guard let shareSession = ShareSessionManager.parseSessionFromNotification(notification) else {
            return
        }
        
        let sharerName = shareSession.sharerAccount.userAccount.fullName
        let message = "Allow \(sharerName) to stop sharing their location with you?"
        self.presentDecisionAlert(message, OKHandler: { (action) -> Void in
            self.sessionManager.sessionTermResponse(shareSession, receiver: self.accountManager.registeredAccount!) {
                (success) -> () in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let message = success ? "You have stopped sharing your location with \(sharerName)." : "Failed to accept location termination request"
                    self.presentErrorAlert(message)
                })
            }
        })
    }
    
    func pickupRequested(notification: NSNotification) {
        guard let shareSession = ShareSessionManager.parseSessionFromNotification(notification) else {
            return
        }
        
        let navigationController = self.storyboard!.instantiateViewControllerWithIdentifier("PickupResponse") as! UINavigationController
        let selectETAController = navigationController.topViewController! as! ReceiverPickUpSharerViewController
        selectETAController.accountManager = accountManager
        selectETAController.sessionManager = sessionManager
        selectETAController.sharerSession = shareSession
        self.presentViewController(navigationController, animated: true, completion: nil)
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
