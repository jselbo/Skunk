//
//  MainTabBarController.swift
//  Skunk
//
//  Created by Josh on 9/24/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("Segue: \(segue)")
    }
}
