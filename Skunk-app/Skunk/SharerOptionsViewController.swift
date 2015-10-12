//
//  SharerOptionsViewController.swift
//  Skunk
//
//  Created by Don Phan on 9/20/15.
//  Copyright © 2015 CS408. All rights reserved.
//

import UIKit

class SharerOptionsViewController: UIViewController, LocationUser {

    var locationManager: LocationManager!
    
    @IBOutlet weak var timeNightOption: UISegmentedControl!
    @IBOutlet weak var timeSelection: UIDatePicker!
    @IBOutlet weak var requestRideOption: UISwitch!
    @IBOutlet weak var selectFriendsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if var destinationController = segue.destinationViewController as? LocationUser {
            destinationController.locationManager = locationManager
        }
    }
    
    
}