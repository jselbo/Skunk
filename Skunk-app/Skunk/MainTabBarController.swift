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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        locationManager = LocationManager()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // At this controller we are guaranteed to have an initialized and saved RegisteredUserAcccount.
        assert(accountManager.registeredAccount != nil)
        
        let shareNavController = viewControllers![0] as! UINavigationController
        let shareController = shareNavController.viewControllers.first! as! ShareMainViewController
        shareController.accountManager = accountManager
        shareController.locationManager = locationManager
        
        let receiveNavController = viewControllers![1] as! UINavigationController
        let receiveController = receiveNavController.viewControllers.first! as! ReceiveFriendsListViewController
        receiveController.accountManager = accountManager
        
        let settingsNavController = viewControllers![2] as! UINavigationController
        let settingsController = settingsNavController.viewControllers.first! as! SettingsViewController
        settingsController.accountManager = accountManager
        
        if accountManager.registeredAccount!.userAccount.debug {
            self.mockDebugRequests()
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
    }
}
