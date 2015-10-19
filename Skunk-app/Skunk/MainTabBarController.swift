//
//  MainTabBarController.swift
//  Skunk
//
//  Created by Josh on 9/24/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

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
    }
}
