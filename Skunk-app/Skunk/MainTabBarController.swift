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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // At this controller we are guaranteed to have an initialized and saved RegisteredUserAcccount.
        assert(accountManager.registeredAccount != nil)
        
        let shareNavController = viewControllers![0] as! UINavigationController
        let shareController = shareNavController.viewControllers.first! as! ShareMainViewController
        shareController.accountManager = accountManager
        
        let receiveNavController = viewControllers![1] as! UINavigationController
        let receiveController = receiveNavController.viewControllers.first! as! ReceiveMainViewController
        receiveController.accountManager = accountManager
    }
}
